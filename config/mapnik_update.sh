#!/bin/bash -xe
# /home/renderaccount/src
FOLDER=${FOLDER:-/home/mapnikdb}
DB_NAME=${DB_NAME:-osm}
OSMOSIS=${OSMOSIS:-$FOLDER/osmosis.run}
DB_PORT=${DB_PORT:-5433}
TILES_DIR=${TILES_DIR:-/var/lib/tirex/tiles/}
TILES_SOCK=${TILES_SOCK:-/var/lib/tirex/modtile.sock}
OSM_STYLE=${OSM_STYLE:-/usr/local/share/osm2pgsql/default.style}
TAG_TRANSFORM_SCRIPT=${TAG_TRANSFORM_SCRIPT:-~/openstreetmap-carto/openstreetmap-carto.lua}
FLAT_NODES_BIN_NAME=${FLAT_NODES_BIN_NAME:-flatnodes.bin}
ID=$(date +"%d_%m_%H_%M")
CHANGES_FILE=$FOLDER/changes_$ID.osc.gz
EXPIRED_FILE=$FOLDER/expired_tiles_$ID.list

echo "CURRENT STATE: "
cat "$FOLDER/osmosis-workdir/state.txt"
cp $FOLDER/osmosis-workdir/state.txt $FOLDER/osmosis-workdir/state-old.txt

$OSMOSIS --rri workingDirectory=$FOLDER/osmosis-workdir --simplify-change --write-xml-change $CHANGES_FILE
echo "FUTURE STATE: "
cat "$FOLDER/osmosis-workdir/state.txt"

cp $FOLDER/osmosis-workdir/state.txt $FOLDER/osmosis-workdir/state-new.txt
cp $FOLDER/osmosis-workdir/state-old.txt $FOLDER/osmosis-workdir/state.txt

# -U jenkins
osm2pgsql --append --slim -d $DB_NAME -P $DB_PORT \
	--hstore --multi-geometry \
	--cache-strategy dense --cache 20000 \
	--number-processes 4 \
	--tag-transform-script $TAG_TRANSFORM_SCRIPT \
	--style $OSM_STYLE \
	--flat-nodes $FOLDER/$FLAT_NODES_BIN_NAME \
	--expire-tiles 13-18 --expire-output $EXPIRED_FILE \
	$CHANGES_FILE
cp $FOLDER/osmosis-workdir/state-new.txt $FOLDER/osmosis-workdir/state.txt

rm $CHANGES_FILE
gzip $EXPIRED_FILE
gzip -cd $EXPIRED_FILE.gz | render_expired --map=default --socket=$TILES_SOCK --tile-dir=$TILES_DIR --num-threads=4 --touch-from=12 --min-zoom=12 >/dev/null
gzip -cd $EXPIRED_FILE.gz | render_expired --map=highres --socket=$TILES_SOCK --tile-dir=$TILES_DIR --num-threads=4 --touch-from=12 --min-zoom=12 >/dev/null
# rm $EXPIRED_FILE.gz

echo "STATE COMMIT: "
cat "$FOLDER/osmosis-workdir/state.txt"
