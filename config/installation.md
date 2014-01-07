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


# configure jenkins
# install repo
$ curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > /bin/repo && chmod a+x /bin/repo

http://dl2.osmand.net:8080/
1. install gerrit repo
2. setup user jenkins (std password)

#CopyIndexes job
*/15 * * * * 
git://github.com/osmandapp/OsmAnd-manifest.git
$ misc/sync_downloads_with_main.sh
$ misc/sync_part_downloads_with_main.sh
$ cd /var/www-download/ && chgrp -R www-data . && chmod -R g+w .

#UpdateNewSite job
git://github.com/osmandapp/OsmAnd-manifest.git
$ misc/update_site.sh

# setup apache2
cd /etc/apache2/
rm sites-enabled/000-default
vi ports.conf # NameVirtualHost *:80 Listen 81
vi sites-available/osmand-download
cd /etc/apache2/sites-enabled && ln -s ../sites-available/osmand-download osmand-download
cd /etc/apache2/mods-enabled/ && ln -s ../mods-available/rewrite.load
vi /etc/apache2/apache2.conf


# setup awstats
 vi /etc/awstats/awstats.ext.conf
 vi /etc/crontab #  5 */1 * * * root /usr/bin/perl /usr/lib/cgi-bin/awstats.pl -config=dl.osmand.net -update > /dev/null


# setup nginx
mkdir -p /var/nginx/client_body_temp && mkdir -p /var/nginx/proxy_temp
chown -R www-data /var/nginx/client_body_temp &&  chown -R www-data /var/nginx/proxy_temp 
vi /etc/nginx/sites-available/osmand-download
cd /etc/nginx/sites-enabled/   && rm default && ln -s ../sites-available/osmand-download osmand-download
