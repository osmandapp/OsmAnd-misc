#!/usr/bin/python
from geoip import geolite2
import os
import re
import sqlite3
import datetime
import gzip

## Load in the log file
def parseLine(var, line):
      res = re.findall(var+"=([^\&\ ]+)", line)
      if len(res) > 0:
            return res[0];
      return ""



if 'gz' in os.environ['LOG_FILE']:
   file = gzip.open( '/var/log/apache2/' + os.environ['LOG_FILE'], 'rb')
else:
   file = open( '/var/log/apache2/' + os.environ['LOG_FILE'])
## Create a database

conn = sqlite3.connect(os.environ['LOG_FILE']+'.sqlite')
c = conn.cursor()

# Build the SQLite database if needed
c.execute('''DROP TABLE  IF EXISTS requests;''')
c.execute('''DROP TABLE  IF EXISTS downloads;''')
c.execute('''VACUUM FULL;''')
c.execute('''CREATE TABLE requests (ip text, land text,
      date time, aid text, ns int, nd int, version text);''')
c.execute('''CREATE TABLE downloads (ip text, land text,
      date time, download text, version text);''')
conn.commit()

print "Prepare data"
## Prepare data
ind = 0
for line in file:
    ind+=1;
    # Parse data from each line
    if "get_indexes" not in line and "/download" not in line :
        continue;
    date = re.findall("\[.*?\]", line)[0][1:-1]
    quoted_data = re.findall("\".*?\"", line)
    if ind % 10000 == 0:
         print "Lines %d" % (ind / 10000)
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

    ## Insert elements into rows
    if "get_indexes" in line:
        c.execute("INSERT INTO requests VALUES (?, ?, ?, ?, ?, ?, ?)", [ip, country, tm, aid, ns, nd, version])
    else:
        c.execute("INSERT INTO downloads VALUES (?, ?, ?, ?, ?)", [ip, country, tm, file, version])

conn.commit()
print "Create indexes"
c.execute('''CREATE INDEX requests_ip on requests (ip);''')
c.execute('''CREATE INDEX requests_aid on requests (aid);''')
conn.commit()

## Check to see if it worked

for row in c.execute("SELECT count(*) from requests"):
    print row