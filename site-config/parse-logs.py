#!/usr/bin/python
from geoip import geolite2
import os
import re
import sqlite3
import datetime
import gzip
import sys
import psycopg2

## Load in the log file
def parseLine(var, line):
      res = re.findall(var+"=([^\&\ ]+)", line)
      if len(res) > 0:
            return res[0];
      return ""


postgres = os.environ['DB_TYPE'] == 'postgres';

if 'gz' in os.environ['LOG_FILE']:
   file = gzip.open( os.environ['LOG_FILE'], 'rb')
else:
   file = open(os.environ['LOG_FILE'])
## Create a database
maxday = ""
if postgres:
    conn_string = "host='localhost' dbname='"+os.environ['DB_NAME']+"' user='"+os.environ['DB_USER']+"' password='"+os.environ['DB_PWD']+"'"
    conn = psycopg2.connect(conn_string)
    c = conn.cursor()
    ## DDL for postgres
    ## CREATE TABLE requests (ip text, land text, date time, day text, aid text, ns int, nd int, version text);
    ## CREATE TABLE downloads (ip text, land text, date time, day text, download text, version text);
    c.execute("select max(day || ' '  || date) from downloads where day = (SELECT max(day)  from downloads)");
    maxday = c.fetchall()[0][0]
else:
    conn = sqlite3.connect(os.environ['LOG_FILE']+'.sqlite')
    c = conn.cursor()
    
    # Build the SQLite database if needed
    c.execute('''DROP TABLE IF EXISTS requests;''')
    c.execute('''DROP TABLE IF EXISTS downloads;''')
    c.execute('''DROP TABLE IF EXISTS geoip;''')
    c.execute('''DROP TABLE IF EXISTS motd;''')
    c.execute('''VACUUM FULL;''')
    c.execute('''CREATE TABLE requests (ip text, land text,
        date time, day text, aid text, ns int, nd int, version text);''')
    c.execute('''CREATE TABLE downloads (ip text, land text,
        date time, day text, download text, version text);''')
    c.execute('''CREATE TABLE geoip(ip text, land text,
        date time, day text);''')
    c.execute('''CREATE TABLE motd (ip text, land text,
        date time, day text, version text);''')
    conn.commit()

print "Prepare data (max day is %s) " % maxday
## Prepare data
ind = 0
skipped = 0;
inserted = 0;
for line in file:
    ind+=1;
    # Parse data from each line
    if ind % 10000 == 0:
        print "Lines %d (skipped %d, inserted %d) " % ((ind / 10000), skipped, inserted)
        sys.stdout.flush()
        conn.commit()
    # if (ind / 10000) < 3918:
    #     continue;
    if ( "/get_indexes" not in line and "/download" not in line 
        and "/motd" not in line and "/geo-ip" not in line ):
        continue;
    try:
        date = re.findall("\[.*?\]", line)[0][1:-1]
        quoted_data = re.findall("\".*?\"", line)

        requested_url = quoted_data[0]
        #referer = quoted_data[1]
        #agent = quoted_data[2]
        #unquoted_data_stream = re.sub("\".*?\"", "", line)    
        unquoted_data_stream = line
        unquoted_data = unquoted_data_stream.split(" ")
        ip = unquoted_data[0]
        version = parseLine("osmandver", requested_url)
        file = parseLine("file", requested_url)
        aid = parseLine("aid", requested_url)
        ns = parseLine("ns", requested_url)
        nd = parseLine("nd", requested_url)
        #response_code = unquoted_data[6]
        match = geolite2.lookup(ip)
        country = ""
        if match is not None: 
            country = match.country
        # print "Ip " + ip + " date " + date + " aid=" + aid + " ns=" + ns+ " nd=" + nd + " ver="+ version
        tm = datetime.datetime.strptime(date[:-6], "%d/%b/%Y:%H:%M:%S")
        day = "%s" % tm;
        day = day[0:10]
        if ns == "":
            ns = None
        if nd == "":
            nd = None
        ##if tm.strftime('%Y-%m-%d %H:%M:%S')  < maxday:
        ##    skipped += 1;
        ##    continue;
        ## Insert elements into rows
        inserted += 1;
        if "get_indexes" in line:
            if postgres:
                c.execute("INSERT INTO requests VALUES (%s, %s, %s, %s, %s, %s, %s, %s)", (ip, country, tm.strftime('%Y-%m-%d %H:%M:%S'), day, aid, ns, nd, version))
            else:
                c.execute("INSERT INTO requests VALUES (?, ?, ?, ?, ?, ?, ?, ?)", [ip, country, tm, day, aid, ns, nd, version])
        elif "/download" in line:
            if postgres:
                c.execute("INSERT INTO downloads VALUES (%s, %s, %s, %s, %s, %s)", (ip, country, tm.strftime('%Y-%m-%d %H:%M:%S'), day, file, version))
            else:
                c.execute("INSERT INTO downloads VALUES (?, ?, ?, ?, ?, ?)", [ip, country, tm, day, file, version])
        elif "/motd" in line:
            if postgres:
                c.execute("INSERT INTO motd VALUES (%s, %s, %s, %s, %s)", (ip, country, tm.strftime('%Y-%m-%d %H:%M:%S'), day, version))
            else:
                c.execute("INSERT INTO motd VALUES (?, ?, ?, ?, ?)", [ip, country, tm, day, version])
        elif "/geo-ip" in line:
            if postgres:
                c.execute("INSERT INTO geoip VALUES (%s, %s, %s, %s)", (ip, country, tm.strftime('%Y-%m-%d %H:%M:%S'), day))
            else:
                c.execute("INSERT INTO geoip VALUES (?, ?, ?, ?)", [ip, country, tm, day])                
    except:
        print line
        print "Unexpected error:", sys.exc_info()[0]


conn.commit()
# if postgres and os.environ['DELETE_DUPLICATES'] == 'true':
#     print "Delete duplicates"
#     c.execute('''DELETE FROM requests r USING requests r2 WHERE r.day = r2.day AND r.date = r2.date AND r.ip = r2.ip AND r.ctid < r2.ctid ;''')
#     c.execute('''DELETE FROM downloads r USING downloads r2 WHERE r.day = r2.day AND r.date = r2.date AND r.ip = r2.ip AND r.ctid < r2.ctid ;''')
#     conn.commit()

if not postgres:
    print "Create indexes"
    c.execute('''CREATE INDEX requests_ip on requests (ip);''')
    c.execute('''CREATE INDEX downloads_ip on downloads (ip);''')
    c.execute('''CREATE INDEX requests_day on requests (day);''')
    c.execute('''CREATE INDEX downloads_day on downloads (day);''')
    c.execute('''CREATE INDEX downloads_dw on downloads (download);''')
    c.execute('''CREATE INDEX requests_version on requests (version);''')
    c.execute('''CREATE INDEX downloads_version on downloads (version);''')
    c.execute('''CREATE INDEX requests_aid on requests (aid);''')
    c.execute('''CREATE INDEX geoip_ip on geoip (ip);''')
    c.execute('''CREATE INDEX geoip_day on geoip (day);''')
    c.execute('''CREATE INDEX motd_day on motd (day);''')
    c.execute('''CREATE INDEX motd_ip on motd (ip);''')
    
    conn.commit()
    for row in c.execute("SELECT count(*) from requests"):
        print row
 
 # CREATE INDEX requests_day on requests (day);
 # ALTER TABLE requests CLUSTER ON requests_day;
 # CLUSTER requests;
 # DELETE FROM requests r USING requests r2 WHERE r.day = r2.day AND r.date = r2.date AND r.ip = r2.ip AND r.ctid < r2.ctid ; 

 # CREATE INDEX downloads_day on downloads (day);
 # ALTER TABLE downloads CLUSTER ON downloads_day;
 # CLUSTER downloads;
 # DELETE FROM downloads r USING downloads r2 WHERE r.day = r2.day AND r.date = r2.date AND r.ip = r2.ip AND r.ctid < r2.ctid ;
############
# CREATE INDEX downloads_dw on downloads (download);
# CREATE INDEX requests_ip on requests (ip);
# CREATE INDEX downloads_ip on downloads (ip);
# CREATE INDEX requests_aid on requests (aid);
##########
# CREATE INDEX requests_version on requests (version);
# CREATE INDEX downloads_version on downloads (version);
