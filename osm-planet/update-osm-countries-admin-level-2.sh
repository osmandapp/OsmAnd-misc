#!/bin/bash
NAME="countries_admin_level_2"
wget -O osm-data/$NAME.osm --post-file=osm-data/queries/$NAME.txt "http://builder.osmand.net:8081/api/interpreter"

sed -i "s/<\/osm>//g" osm-data/$NAME.osm
cat osm-data/queries/$NAME-addition.txt >> osm-data/$NAME.osm
echo "</osm>" >> osm-data/$NAME.osm
sed -i '/member type=/d' ./osm-data/$NAME.osm