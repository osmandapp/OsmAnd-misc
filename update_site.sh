#!/bin/sh
DIRECTORY=$(cd `dirname $0` && pwd)

GIT_SITE_DIR=$DIRECTORY/site/
LOCAL_SITE_DIR=/var/www-download/
DVR_SITE_DIR=/var/www-dvr/


mkdir -p $LOCAL_SITE_DIR/
cp -vur $GIT_SITE_DIR/* $LOCAL_SITE_DIR 
cp -vu $GIT_SITE_DIR/../../resources/countries-info/countries.xml $LOCAL_SITE_DIR/countries.xml
cp -vur ../help/website/* $LOCAL_SITE_DIR
chgrp -R www-data $LOCAL_SITE_DIR/*

chmod g+w $LOCAL_SITE_DIR/indexes.xml 

cp -vur ../help/dvr/* $DVR_SITE_DIR
chgrp -R www-data $LOCAL_SITE_DIR/*


