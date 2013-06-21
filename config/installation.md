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


# configure jenkins
# install repo
$ curl https://dl-ssl.google.com/dl/googlesource/git-repo/repo > /bin/repo && chmod a+x /bin/repo

http://dl2.osmand.net:8080/
1. install gerrit repo
2. setup user jenkins (std password)

#CopyIndexes job
   */15 * * * * 
   git://github.com/osmandapp/OsmAnd-manifest.git
$ misc/sync_downloads_with_main.sh
$ cd /var/www-download/ && chgrp -R www-data . && chmod -R g+w .

#Update new site
git://github.com/osmandapp/OsmAnd-manifest.git
$ misc/update_site.sh

# setup apache2
rm sites-enabled/000-default
vi ports.conf # 81
vi httpd.conf # ServerName dl.osmand.net # if file exists
vi sites-available/osmand-default
ln -s ../sites-available/osmand-download osmand-download
cd /etc/apache2/mods-enabled/ && ln -s ../mods-available/rewrite.load


# setup awstats
 vi /etc/awstats/awstats.ext.conf
 vi /etc/crontab #  5 */1 * * * root /usr/bin/perl /usr/lib/cgi-bin/awstats.pl -config=dl.osmand.net -update > /dev/null


# setup nginx

