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
