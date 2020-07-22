#!/bin/bash
wget -O osm-data/states_regions.osm --post-file=osm-data/queries/states_regions.txt "https://z.overpass-api.de/api/interpreter"
sed -i '/member type=/d' ./osm-data/states_regions.osm
sed -i '0,/k="name" v="Bas-Rhin"/{s/k="name" v="Bas-Rhin"/k="name" v="1"/}' ./osm-data/states_regions.osm
sed -i '0,/k="name:en" v="Luzhou City"/{s/k="name:en" v="Luzhou City"/k="name:en" v="1"/}' ./osm-data/states_regions.osm
sed -i '0,/k="name:en" v="Yibin City"/{s/k="name:en" v="Yibin City"/k="name:en" v="1"/}' ./osm-data/states_regions.osm
sed -i '0,/k="name:en" v="Zhaotong City"/{s/k="name:en" v="Zhaotong City"/k="name:en" v="1"/}' ./osm-data/states_regions.osm
sed -i '0,/k="name" v="Moselle"/{s/k="name" v="Moselle"/k="name" v="1"/}' ./osm-data/states_regions.osm
sed -i '0,/k="name:en" v="Garzê Tibetan Autonomous Prefecture"/{s/k="name:en" v="Garzê Tibetan Autonomous Prefecture"/k="name" v="1"/}' ./osm-data/states_regions.osm
sed -i '0,/k="name:en" v="Chamdo City"/{s/k="name:en" v="Chamdo City"/k="name:en" v="1"/}' ./osm-data/states_regions.osm
sed -i '0,/k="name:en" v="Nizhnekolymsky Ulus"/{s/k="name:en" v="Nizhnekolymsky Ulus"/k="name:en" v="1"/}' ./osm-data/states_regions.osm
sed -i '0,/k="name:en" v="Inta Urban Okrug"/{s/k="name:en" v="Inta Urban Okrug"/k="name:en" v="1"/}' ./osm-data/states_regions.osm
sed -i '0,/k="name:en" v="Pechora Municipal District"/{s/k="name:en" v="Pechora Municipal District"/k="name:en" v="1"/}' ./osm-data/states_regions.osm
sed -i '0,/k="name:en" v="Taymyrsky Dolgano-Nenetsky District"/{s/k="name:en" v="Taymyrsky Dolgano-Nenetsky District"/k="name:en" v="1"/}' ./osm-data/states_regions.osm
sed -i '0,/k="name:en" v="Tazovsky Rayon"/{s/k="name:en" v="Tazovsky Rayon"/k="name:en" v="1"/}' ./osm-data/states_regions.osm
