#!/bin/bash
NAME="states_regions"
wget -O osm-data/states_regions.osm --post-file=osm-data/queries/$NAME.txt "https://z.overpass-api.de/api/interpreter"
sed -i "s/<\/osm>//g" osm-data/$NAME.osm
cat osm-data/queries/$NAME-addition.txt >> osm-data/$NAME.osm
sed -i '/member type=/d' ./osm-data/$NAME.osm
sed -i '0,/k="name:en" v="Aksai Chin"/{s/k="name:en" v="Aksai Chin"/k="name:en" v="1"/}' ./osm-data/$NAME.osm
echo "</osm>" >> osm-data/$NAME.osm