#!/bin/bash
BASE=/var/lib/jenkins/osm-planet/regions
PBF_FILES="/var/lib/jenkins/workspace/Planet_Update-Extract Osm Maps Downloads/extracted/"


updateRegion() {
	echo "Update ${1} using ${2}"
	FILE="${BASE}/${1}.o5m"
	if [ ! -f $FILE ]; then
		osmconvert --out-o5m "${PBF_FILES}/${3}" -B=misc/osm-planet/${2} > ${FILE} 
	fi
    osmupdate $FILE ${BASE}/current-update.o5m -B=misc/osm-planet/${2} -v
    osmconvert --out-pbf $FILE > ${BASE}/${1}.osm.pbf
    mv -f $FILE ${FILE}.old || true
    # rm ${BASE}/${1}.o5m
    mv ${BASE}/current-update.o5m $FILE
}

rm current-update.o5m || true

#HOT OSM
updateRegion Nepal polygons/east-asia/nepal.poly nepal.pbf
