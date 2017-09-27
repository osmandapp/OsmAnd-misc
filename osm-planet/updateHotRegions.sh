#!/bin/bash
BASE="/var/lib/jenkins/hot-regions"
PBF_FILES="/home/osm-planet/osm-extract"

rm $BASE/*.*

updateRegion() {
	echo "Update ${1} using ${2}"
	FILE="${BASE}/${3%%.*}.o5m"
	if [ ! -f $FILE ]; then
		osmconvert --out-o5m "${PBF_FILES}/${3%%.*}/${3}" -B=misc/osm-planet/${2} > ${FILE} 
	fi
    osmupdate $FILE $(osmconvert $FILE --out-statistics | grep 'timestamp max' | sed 's/timestamp max: //g') ${BASE}/current-update.o5m -B=misc/osm-planet/${2} -v
    osmconvert --out-pbf $FILE > ${BASE}/${1}.osm.pbf
    mv -f $FILE ${FILE}.old || true
    # rm ${BASE}/${1}.o5m
    mv ${BASE}/current-update.o5m $FILE
}

rm current-update.o5m || true

#HOT OSM
updateRegion Mexico polygons/north-america/mexico.poly mexico_northamerica.pbf
updateRegion Mexico_nuevo-leon polygons/north-america/mexico/nuevo-leon.poly mexico_nuevo-leon_northamerica.pbf

# updateRegion Nepal polygons/east-asia/nepal.poly nepal.pbf
