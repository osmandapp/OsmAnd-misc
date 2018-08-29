#!/bin/sh
DIRECTORY=$(cd `dirname $0` && pwd)

GIT_SITE_DIR=$DIRECTORY/site/
if [ -z "$LOCAL_SITE_DIR" ]; then
	LOCAL_SITE_DIR=/var/www-download/
fi
mkdir -p $LOCAL_SITE_DIR/
cp -vur $GIT_SITE_DIR/* $LOCAL_SITE_DIR 
# cp -vu $GIT_SITE_DIR/../../resources/countries-info/countries.xml $LOCAL_SITE_DIR/countries.xml

mkdir -p $LOCAL_SITE_DIR/hillshade
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

cp misc/config/nginx-main/server-include.conf /etc/nginx/server-include/ || true
sudo service nginx reload || true

cp -vur help/website/* $LOCAL_SITE_DIR
rsync -arv --delete help/website/ $LOCAL_SITE_DIR/web/
# curl -fSL https://github.com/osmandapp/OsmAnd-resources/raw/master/countries-info/regions.ocbf > $LOCAL_SITE_DIR/regions_v2.ocbf

## LEGACY
# cp -vu help/website/help/map-legend.html $LOCAL_SITE_DIR/help/Map-Legend_default.html
# cp -vu help/website/help/technical-articles.html $LOCAL_SITE_DIR/help/TechnicalArticles.html
# cp -vu help/website/help/legacy/HowToArticles.html $LOCAL_SITE_DIR/help/HowToArticles.html


chgrp -R www-data $LOCAL_SITE_DIR/*
chmod g+w $LOCAL_SITE_DIR/indexes.xml 