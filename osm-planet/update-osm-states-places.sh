#!/bin/zsh -x
wget -O osm-data/states_places.osm --post-file=osm-data/queries/states_places.txt "https://overpass.kumi.systems/api/interpreter"

./us-states-abbreviations.sh "osm-data/states_places.osm"