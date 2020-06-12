#!/bin/bash
wget -O osm-data/countries_places.osm --post-file=osm-data/queries/countries_places.txt "https://overpass.kumi.systems/api/interpreter"