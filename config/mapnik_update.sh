export FOLDER=/home/posgres/
ID=`(date +"%d_%m_%H_%M")`
$FOLDER/osmosis.run --rri workingDirectory=$FOLDER/osmosis-workdir --simplify-change --write-xml-change $FOLDER/changes$ID.osc.gz

# -U jenkins
osm2pgsql --append --style /usr/local/share/osm2pgsql/default.style \
-k --flat-nodes /postgresql/flatnodes \
--number-processes 4 -C 25000 -d gis --slim  --expire-tiles 13-18 \
--expire-output $FOLDER/expired_tiles$ID.list $FOLDER/changes$ID.osc.gz

ls -larh $FOLDER/changes$ID.osc.gz
rm $FOLDER/changes$ID.osc.gz

bzip2 $FOLDER/expired_tiles$ID.list
bzcat $FOLDER/expired_tiles$ID.list.bz2 | render_expired --map=default --socket=/var/lib/tirex/modtile.sock --tile-dir=/var/lib/tirex/tiles/ --num-threads=4 --touch-from=13 --min-zoom=13
bzcat $FOLDER/expired_tiles$ID.list.bz2 | render_expired --map=highres --socket=/var/lib/tirex/modtile.sock --tile-dir=/var/lib/tirex/tiles/ --num-threads=4 --touch-from=13 --min-zoom=13
rm $FOLDER/expired_tiles$ID.list.bz2

# bzcat $FOLDER/expired_tiles$ID.list.bz2 | $FOLDER/mod_tile/render_expired --touch-from=13 --min-zoom=13
#rm $FOLDER/expired_tiles$ID.list
