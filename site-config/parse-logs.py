#!/usr/bin/python
import os
import re
import sqlite3

## Load in the log file
def parseLine(var, line):
      res = re.findall(var+"=([^\&\ ]+)", line)
      if len(res) > 0:
            return res[0];
      return ""

file = open( '/var/log/apache2/' + os.environ['LOG_FILE'])
## Create a database

conn = sqlite3.connect(os.environ['LOG_FILE']+'.sqlite')
c = conn.cursor()

# Build the SQLite database if needed
c.execute('''CREATE TABLE requests (ip text, 
      date text, requested_url text, response_code int, referer text, agent text);''')
conn.commit()

## Prepare data
for line in file:
    # Parse data from each line
    if "get_indexes" not in line:
        continue;
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
    aid = parseLine("aid", requested_url)
    ns = parseLine("ns", requested_url)
    nd = parseLine("nd", requested_url)
    #response_code = unquoted_data[6]

    print "Ip " + ip + " date " + date + " aid=" + aid + " ns=" + ns+ " nd" + nd + " ver="+ version

    ## Insert elements into rows
    #c.execute("INSERT INTO requests VALUES (?, ?, ?, ?, ?, ?)", [ip, date, requested_url, response_code, referer, agent])

conn.commit()

## Check to see if it worked

for row in c.execute("SELECT count(*) from requests"):
    print row
