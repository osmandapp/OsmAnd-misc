#!/bin/bash -xe
DIRECTORY=$(cd `dirname $0` && pwd)
if [ -z "$LOCAL_SITE_DIR" ]; then
	LOCAL_SITE_DIR=/var/www-download
fi
mkdir -p $LOCAL_SITE_DIR
mkdir -p $LOCAL_SITE_DIR/website
cd "$LOCAL_SITE_DIR/website"
if [ ! -d "$LOCAL_SITE_DIR/website/.git" ]; then
 git init 
 git remote add origin https://github.com/osmandapp/web-server-config.git
 git fetch
 git reset origin/main
 git checkout -t origin/main
else 
 git pull
fi
# (if doesn't exist) git clone https://github.com/osmandapp/osmandapp.github.io.git $LOCAL_SITE_DIR

mkdir -p $LOCAL_SITE_DIR/hillshade
mkdir -p $LOCAL_SITE_DIR/depth
mkdir -p $LOCAL_SITE_DIR/indexes
mkdir -p $LOCAL_SITE_DIR/road-indexes
mkdir -p $LOCAL_SITE_DIR/srtm
mkdir -p $LOCAL_SITE_DIR/srtm-countries
mkdir -p $LOCAL_SITE_DIR/night-builds
mkdir -p $LOCAL_SITE_DIR/latest-night-build
mkdir -p $LOCAL_SITE_DIR/gen
# mkdir -p $LOCAL_SITE_DIR/releases
# mkdir -p $LOCAL_SITE_DIR/osm-releases

# builder.osmand.net
# ln -s /home/releases/releases
# ln -s /home/releases/osm-releases
# ln -s /home/basemap
# ln -s /home/binaries/prebuilt
# ln -s /home/binaries/binaries
# ln -s /home/binaries/dependencies-mirror
# ln -s /home/binaries/legacy-dependencies-mirror
# ln -s /home/binaries/ivy
# ln -s /home/www/hillshade
# ln -s /home/www/indexes
# ln -s /home/www/night-builds
# ln -s /home/osm-planet/osmc/
# ln -s /home/osm-planet/osm-extract/
# ln -s /home/osm-planet/osmlive
# ln -s /home/www/road-indexes
# ln -s /home/relief-data/contours-osm-bz2/ srtm
# ln -s /home/www/srtm-countries
# ln -s /mnt/home-hdd/relief-data/terrain-aster-srtm-eudem
# ln -s /home/www/wiki
# ln -s /home/www/wikigen

cp misc/config/nginx-main/*.conf /etc/nginx/server-include/ || true
sudo service nginx reload || true

chgrp -R www-data $LOCAL_SITE_DIR/*