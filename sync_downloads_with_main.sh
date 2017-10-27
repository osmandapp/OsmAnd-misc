#!/bin/bash
function sync {
	rsync --progress --delete-after --dirs --times jenkins@download.osmand.net:$1 $1
}
sync /var/www-download/indexes/
sync /var/www-download/hillshade/
sync /var/www-download/srtm-countries/
sync /var/www-download/road-indexes/
sync /var/www-download/wiki/
