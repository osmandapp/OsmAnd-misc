#!/bin/sh
DIRECTORY=$(cd `dirname $0` && pwd)

GIT_SITE_DIR=$DIRECTORY/site/
LOCAL_SITE_DIR=/var/www-download/
DVR_SITE_DIR=/var/www-dvr/


mkdir -p $LOCAL_SITE_DIR/

cp -vur $GIT_SITE_DIR/* $LOCAL_SITE_DIR 
cp -vu $GIT_SITE_DIR/../../resources/countries-info/countries.xml $LOCAL_SITE_DIR/countries.xml

cp -vur help/website/* $LOCAL_SITE_DIR
## LEGACY
cp -vu help/website/help/map-legend.html $LOCAL_SITE_DIR/help/Map-Legend_default.html
cp -vu help/website/help/technical-articles.html $LOCAL_SITE_DIR/help/TechnicalArticles.html
cp -vu help/website/help/legacy/HowToArticles.html $LOCAL_SITE_DIR/help/HowToArticles.html

chgrp -R www-data $LOCAL_SITE_DIR/*
chmod g+w $LOCAL_SITE_DIR/indexes.xml 

if [ -d "$DVR_SITE_DIR" ]; then 
	cp -vur help/dvr/* $DVR_SITE_DIR
	chgrp -R www-data $DVR_SITE_DIR/*
fi



