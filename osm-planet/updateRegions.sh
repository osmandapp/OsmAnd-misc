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
# Europe
updateRegion England-london geo-polygons/europe/great-britain/england/greater-london.poly europe.pbf
updateRegion England-birmingham polygons/europe/gb-metropolises/birmingham.poly europe.pbf
updateRegion England-leeds polygons/europe/gb-metropolises/leeds.poly europe.pbf
 
updateRegion France-paris polygons/europe/france-metropolises/paris.poly europe.pbf
updateRegion France-lyon polygons/europe/france-metropolises/lyon.poly europe.pbf
updateRegion France-marseille polygons/europe/france-metropolises/marseille.poly europe.pbf
updateRegion France-toulouse polygons/europe/france-metropolises/toulouse.poly europe.pbf

updateRegion Germany-munich polygons/europe/germany-metropolises/munchen.poly europe.pbf
updateRegion German-ruhregebiet-koln polygons/europe/germany-metropolises/ruhrgebiet-koln.poly europe.pbf

updateRegion Italy-roma polygons/europe/italy-metropolises/italy.poly europe.pbf

updateRegion Spain-madrid polygons/europe/spain-metropolises/madrid.poly europe.pbf

# Russia
updateRegion Russia-sankt-petersburg polygons/russia-regions/sankt-peterburg.poly russia.pbf
updateRegion Russia-moscow polygons/russia-regions/moscow.poly russia.pbf
updateRegion Russia-moscovskaya-oblast polygons/russia-regions/moskovskaya-oblast.poly russia.pbf

ls -larh ${BASE}
