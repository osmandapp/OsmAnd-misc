#!/bin/bash
wget -O osm-data/states_regions.osm --post-file=osm-data/queries/states_regions.txt "https://z.overpass-api.de/api/interpreter"
sed -i '/member type=/d' ./osm-data/states_regions.osm
