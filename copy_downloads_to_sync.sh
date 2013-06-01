#!/bin/sh
DIRECTORY=$(cd `dirname $0` && pwd)

INDEXES_DIR=/var/www-download/indexes/
SYNC_DIR=/var/www-download/sync/

# R2NGOYG7TSJL7BT5QB5QFULORCH7TQ43X
rsync --progress --include=Russia_* --exclude=* $INDEXES_DIR/* $SYNC_DIR/Russia/

rsync --progress --include=*_europe_* --exclude=* $INDEXES_DIR/* $SYNC_DIR/Europe/

rsync --progress --include=*_northamerica_* --exclude=* $INDEXES_DIR/* $SYNC_DIR/NorthAmerica/
