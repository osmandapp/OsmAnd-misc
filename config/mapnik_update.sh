#!/bin/bash -xe
# /home/renderaccount/src
FOLDER=${FOLDER:-/home/mapnikdb}
DB_NAME=${DB_NAME:-osm}
# OSMOSIS=${OSMOSIS:-$FOLDER/osmosis.run}
DB_PORT=${DB_PORT:-5433}
TILES_DIR=${TILES_DIR:-/var/lib/tirex/tiles/}
TILES_SOCK=${TILES_SOCK:-/var/lib/tirex/modtile.sock}
OSM_STYLE=${OSM_STYLE:-/usr/local/share/osm2pgsql/default.style}
TAG_TRANSFORM_SCRIPT=${TAG_TRANSFORM_SCRIPT:-~/openstreetmap-carto/openstreetmap-carto.lua}
FLAT_NODES_BIN_NAME=${FLAT_NODES_BIN_NAME:-flatnodes.bin}
ID=$(date +"%d_%m_%H_%M")
CHANGES_FILE=$FOLDER/changes_$ID.osc.gz
EXPIRED_FILE=$FOLDER/expired_tiles_$ID.list

STATE_FOLDER=osmupdate #osmosis-workdir
echo "CURRENT STATE: "
cat "$FOLDER/$STATE_FOLDER/state.txt"
cp $FOLDER/$STATE_FOLDER/state.txt $FOLDER/$STATE_FOLDER/state-old.txt

# $OSMOSIS --rri workingDirectory=$FOLDER/osmosis-workdir --simplify-change --write-xml-change $CHANGES_FILE
TIMESTAMP=$(cat "$FOLDER/$STATE_FOLDER/state.txt")
osmupdate $TIMESTAMP $CHANGES_FILE
ls -lar $CHANGES_FILE
echo $(osmconvert --out-timestamp  $CHANGES_FILE) > "$FOLDER/$STATE_FOLDER/state.txt"

echo "FUTURE STATE: "
cat "$FOLDER/$STATE_FOLDER/state.txt"

cp $FOLDER/$STATE_FOLDER/state.txt $FOLDER/$STATE_FOLDER/state-new.txt
cp $FOLDER/$STATE_FOLDER/state-old.txt $FOLDER/$STATE_FOLDER/state.txt

exit 0

# -U jenkins
osm2pgsql --append --slim -d $DB_NAME -P $DB_PORT \
	--hstore --multi-geometry \
	--cache-strategy dense --cache 20000 \
	--number-processes 4 \
	--tag-transform-script $TAG_TRANSFORM_SCRIPT \
	--style $OSM_STYLE \
	--flat-nodes $FOLDER/$FLAT_NODES_BIN_NAME \
	--expire-tiles 12-18 --expire-output $EXPIRED_FILE \
	$CHANGES_FILE
cp $FOLDER/$STATE_FOLDER/state-new.txt $FOLDER/$STATE_FOLDER/state.txt

rm $CHANGES_FILE
gzip $EXPIRED_FILE
gzip -cd $EXPIRED_FILE.gz | render_expired --map=default --socket=$TILES_SOCK --tile-dir=$TILES_DIR --num-threads=4 --touch-from=12 --min-zoom=12 >/dev/null
gzip -cd $EXPIRED_FILE.gz | render_expired --map=highres --socket=$TILES_SOCK --tile-dir=$TILES_DIR --num-threads=4 --touch-from=12 --min-zoom=12 >/dev/null

rm $EXPIRED_FILE.gz

echo "STATE COMMIT: "
cat "$FOLDER/$STATE_FOLDER/state.txt"
