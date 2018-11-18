#!/bin/bash
ID=`(date +"%d_%m_%H_%M")`
cat "CURRENT STATE: $FOLDER/osmosis-workdir/state.txt"
cp $FOLDER/osmosis-workdir/state.txt $FOLDER/osmosis-workdir/state-old.txt

$FOLDER/osmosis.run --rri workingDirectory=$FOLDER/osmosis-workdir --simplify-change --write-xml-change $FOLDER/changes$ID.osc.gz
cat "FUTURE STATE: $FOLDER/osmosis-workdir/state.txt"
cp $FOLDER/osmosis-workdir/state.txt $FOLDER/osmosis-workdir/state-new.txt
cp $FOLDER/osmosis-workdir/state-old.txt $FOLDER/osmosis-workdir/state.txt

# -U jenkins
osm2pgsql --append --slim -d osm -P 5433 --cache-strategy dense \
	--cache 40000 --number-processes 4 --hstore \
 	--style /usr/local/share/osm2pgsql/default.style  --multi-geometry \
 	--flat-nodes $FOLDER/flatnodes.bin \
	--expire-tiles 13-18 --expire-output $FOLDER/expired_tiles$ID.list \
	$FOLDER/changes$ID.osc.gz

ls -larh $FOLDER/changes$ID.osc.gz
rm $FOLDER/changes$ID.osc.gz

bzip2 $FOLDER/expired_tiles$ID.list
bzcat $FOLDER/expired_tiles$ID.list.bz2 | render_expired --map=default --socket=/var/lib/tirex/modtile.sock --tile-dir=/var/lib/tirex/tiles/ --num-threads=4 --touch-from=13 --min-zoom=13
bzcat $FOLDER/expired_tiles$ID.list.bz2 | render_expired --map=highres --socket=/var/lib/tirex/modtile.sock --tile-dir=/var/lib/tirex/tiles/ --num-threads=4 --touch-from=13 --min-zoom=13
rm $FOLDER/expired_tiles$ID.list.bz2

# bzcat $FOLDER/expired_tiles$ID.list.bz2 | $FOLDER/mod_tile/render_expired --touch-from=13 --min-zoom=13
#rm $FOLDER/expired_tiles$ID.list
cp $FOLDER/osmosis-workdir/state-new.txt $FOLDER/osmosis-workdir/state.txt
cat "STATE COMMIT: $FOLDER/osmosis-workdir/state.txt"