#!/bin/bash
wget -O osm-data/countries_places.osm --post-file=osm-data/queries/countries_places.txt "http://builder.osmand.net:8081/api/interpreter"