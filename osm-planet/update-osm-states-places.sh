#!/bin/bash
wget -O osm-data/states_places.osm --post-file=osm-data/queries/states_places.txt "http://builder.osmand.net:8081/api/interpreter"