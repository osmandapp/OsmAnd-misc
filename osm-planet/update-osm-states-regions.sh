#!/bin/bash
NAME="states_regions"
wget -O osm-data/states_regions.osm --post-file=osm-data/queries/$NAME.txt "https://z.overpass-api.de/api/interpreter"
sed -i "s/<\/osm>//g" osm-data/$NAME.osm
sed -i '/member type=/d' ./osm-data/$NAME.osm

#Translates
> osm-data/flanders_brussel.osm
./combine_translations.sh osm-data/$NAME.osm 53134 54094 osm-data/flanders_brussel.osm
cat osm-data/flanders_brussel.osm >> osm-data/$NAME.osm

> osm-data/brandenburg_berlin.osm
./combine_translations.sh osm-data/$NAME.osm 62504 62422 osm-data/brandenburg_berlin.osm
cat osm-data/brandenburg_berlin.osm >> osm-data/$NAME.osm

echo "</osm>" >> osm-data/$NAME.osm