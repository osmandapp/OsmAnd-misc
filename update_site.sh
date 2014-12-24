#!/bin/sh
DIRECTORY=$(cd `dirname $0` && pwd)

GIT_SITE_DIR=$DIRECTORY/site/
LOCAL_SITE_DIR=/var/www-download/

mkdir -p $LOCAL_SITE_DIR/
mkdir -p $LOCAL_SITE_DIR/static/
cp -vur $GIT_SITE_DIR/* $LOCAL_SITE_DIR && \
cp -vur $DIRECTORY/../help/website/* $LOCAL_SITE_DIR/static/ && \
cp -vu $GIT_SITE_DIR/../../resources/countries-info/countries.xml $LOCAL_SITE_DIR/countries.xml && \
chgrp -R www-data $LOCAL_SITE_DIR/*
chmod g+w $LOCAL_SITE_DIR/indexes.xml 
#files='*.php tile_sources.xml favicon.ico'
#for f in $files ; do
#	cp $GIT_SITE_DIR/$f $LOCAL_SITE_DIR/ -u;
#done