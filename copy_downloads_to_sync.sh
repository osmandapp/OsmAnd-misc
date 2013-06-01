#!/bin/sh
DIRECTORY=$(cd `dirname $0` && pwd)

INDEXES_DIR=/var/www-download/indexes/
SYNC_DIR=/var/www-download/sync/

# R2NGOYG7TSJL7BT5QB5QFULORCH7TQ43X
mkdir -p $SYNC_DIR/Russia
rsync --progress --delete-after --times --include=Russia_* --exclude=* $INDEXES_DIR/* $SYNC_DIR/Russia/

mkdir -p $SYNC_DIR/Europe
rsync --progress --delete-after --times  --include=*_europe_* --exclude=* $INDEXES_DIR/* $SYNC_DIR/Europe/

mkdir -p $SYNC_DIR/NorthAmerica
rsync --progress --delete-after --times  --include=*_northamerica_* --exclude=* $INDEXES_DIR/* $SYNC_DIR/NorthAmerica/
