#!/bin/bash
wget -O osm-data/states_regions.osm --post-file=osm-data/queries/states_regions.txt "https://z.overpass-api.de/api/interpreter"
sed -i '/member type=/d' ./osm-data/states_regions.osm
sed -i '0,/k="name" v="Bas-Rhin"/{s/k="name" v="Bas-Rhin"/k="name" v="1"/}' ./osm-data/states_regions.osm
sed -i '0,/k="name:en" v="Luzhou City"/{s/k="name:en" v="Luzhou City"/k="name:en" v="1"/}' ./osm-data/states_regions.osm
sed -i '0,/k="name:en" v="Yibin City"/{s/k="name:en" v="Yibin City"/k="name:en" v="1"/}' ./osm-data/states_regions.osm
sed -i '0,/k="name:en" v="Zhaotong City"/{s/k="name:en" v="Zhaotong City"/k="name:en" v="1"/}' ./osm-data/states_regions.osm