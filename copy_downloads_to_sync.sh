#!/bin/sh
DIRECTORY=$(cd `dirname $0` && pwd)

INDEXES_DIR=/var/www-download/indexes/
SYNC_DIR=/var/sync/

# R2NGOYG7TSJL7BT5QB5QFULORCH7TQ43X
mkdir -p $SYNC_DIR/Russia
rsync --progress --delete-after --times $INDEXES_DIR/Russia_* $SYNC_DIR/Russia/

mkdir -p $SYNC_DIR/France
rsync --progress --delete-after --times  $INDEXES_DIR/France* $SYNC_DIR/France/

mkdir -p $SYNC_DIR/GB
rsync --progress --delete-after --times  $INDEXES_DIR/Gb_* $SYNC_DIR/GB/

mkdir -p $SYNC_DIR/Germany
rsync --progress --delete-after --times  $INDEXES_DIR/Germany_* $SYNC_DIR/Germany/

# R7MSXJBL7PDB74LI3A5HTIUQ7QDQE5ITU
mkdir -p $SYNC_DIR/Europe
rsync --progress --delete-after --times --exclude="(France|Gb_|Germany)*" $INDEXES_DIR/*_europe_* $SYNC_DIR/Europe/

# RJ6BUYMK4CDT64G3JZWVKAK2UPNGALXXI
mkdir -p $SYNC_DIR/NorthAmerica
rsync --progress --delete-after --times $INDEXES_DIR/*_northamerica_* $SYNC_DIR/NorthAmerica/
