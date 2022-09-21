#!/bin/bash
function sync {
	rsync -r --progress --delete-after --dirs --times jenkins@download.osmand.net:/var/www-download/$1 /var/www-download/$1
}

sync indexes/
#sync hillshade/
#sync slope/
sync depth/
sync srtm-countries/
sync road-indexes/
sync wiki/
sync wikivoyage/
sync travel/
#sync aosmc/
#sync osm-releases/
#sync releases/
#sync latest-night-build/
