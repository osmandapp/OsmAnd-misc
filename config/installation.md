#!/bin/sh
# Ubuntu
ssh root@dl.osmand.net
vi .ssh/authorized_keys
## vi /etc/hostname # ?

# apt-get
apt-get install git jenkins openjdk-6-jdk nginx apache2 php5 ant python2.7 vim curl wget perl awstats
su jenkins
ssh-keygen # register at download.osmand.net
ssh jenkins@download.osmand.net #to check for osmand jobs

# configure folders
mkdir /var/www-download/ && chgrp -R www-data /var/www-download/ \
&& chown -R jenkins /var/www-download/ &&  usermod -a -G www-data jenkins
service jenkins restart


# traffic
apt-get install vnstat iptraf
vi /etc/vnstat.conf # MaxBandwidth
service vnstat restart #!


# setup nginx
mkdir -p /var/nginx/client_body_temp && mkdir -p /var/nginx/proxy_temp
chown -R www-data /var/nginx/client_body_temp &&  chown -R www-data /var/nginx/proxy_temp 
vi /etc/nginx/sites-available/osmand-download
cd /etc/nginx/sites-enabled/   && rm default && ln -s ../sites-available/osmand-download osmand-download
