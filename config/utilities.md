# Calculate traffic from access.log
zcat /var/log/apache2/access.log.2.gz | grep germany | wc -l
cat /var/log/apache2/access.log | grep europe | perl -e 'my $sum=0; while(<>) { my ($traffic) = m/\[.+\] ".+" \d+ (\d+)
 /; $sum += $traffic}; $sum = $sum/(1024.*1024.*1024.) ; print "$sum GB\n"'


COUNTRIES=( 'World' 'German' 'France' 'Russia' 'Italy' 'Gb' 'Netherlands' 'Spain' 'Austria'  'Poland' 'Canada'  'Japan' 'Sweden' 'Us' 'Belarus' 'Denmark'  'Czech' 'Brazil' 'Australia' 'Belgium' 'Finland' 'Norway' )
for i in "${COUNTRIES[@]}"; do 	echo $i;  cat /var/log/apache2/access.log.1 | grep $i | grep 302 | wc -l; done 



# awstats
rm /var/lib/awstats/* && perl /usr/lib/cgi-bin/awstats.pl config=ovh.osmand.net -update


# Monitor traffic
vnstat -h
ipstat

# test speed
cd /tmp
git clone https://github.com/sivel/speedtest-cli
cd speedtest-cli 
python2.7 speedtest-cli


# Fix timestamps script on FS
import os, zipfile, time, datetime
from dateutil.tz import *
for root, dirs, filenames in os.walk('.'):
	for f in filenames:
		if not f.endswith("obf.zip"):
			continue;
		with zipfile.ZipFile(f, "r") as myzip:
			info = myzip.getinfo(f[0: -4])
			if info is not None:
				a = info.date_time
				print a
				t = datetime.datetime(*a, tzinfo=tzlocal())
				print f
				print t
				ts = (t-datetime.datetime(1970, 1, 1, tzinfo=tzutc())).total_seconds()
				os.utime(f, (ts, ts))




