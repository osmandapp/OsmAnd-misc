#!/bin/zsh -x
wget -O osm-data/states_places.osm --post-file=osm-data/queries/states_places.txt "https://maps.mail.ru/osm/tools/overpass/api/interpreter"

./us-states-abbreviations.sh "osm-data/states_places.osm"