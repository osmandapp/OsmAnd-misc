#!/bin/bash
wget -O osm-data/countries_places.osm --post-file=osm-data/queries/countries_places.txt "http://overpass-api.de/api/interpreter"