#!/bin/bash
BASE=/var/lib/jenkins/osm-planet/regions

updateRegion() {
	echo "Update ${1} using ${2}"
    osmupdate ${BASE}/${1}.o5m ${BASE}/current-update.o5m -B=misc/osm-planet/polygons/${2} -v
    osmconvert --out-pbf ${BASE}/${1}.o5m > ${BASE}/${1}.osm.pbf
    mv -f ${1} ${1}.o5m.old || true
    # rm ${BASE}/${1}.o5m
    mv ${BASE}/current-update.o5m ${BASE}/${1}.o5m
}

rm current-update.o5m || true
updateRegion Russia-sankt-petersburg russia-regions/sankt-peterburg.poly
updateRegion Russia-moscow russia-regions/moscow.poly

ls -larh ${BASE}


