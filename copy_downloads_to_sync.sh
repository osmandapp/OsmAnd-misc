#!/bin/sh
DIRECTORY=$(cd `dirname $0` && pwd)

INDEXES_DIR=/var/www-download/indexes/
SYNC_DIR=/var/www-download/sync/

# R2NGOYG7TSJL7BT5QB5QFULORCH7TQ43X
rsync --include=*Russia_* $INDEXES_DIR $SYNC_DIR/Russia

rsync --include=*_europe_* $INDEXES_DIR $SYNC_DIR/Europe

rsync --include=*_northamerica_* $INDEXES_DIR $SYNC_DIR/NorthAmerica