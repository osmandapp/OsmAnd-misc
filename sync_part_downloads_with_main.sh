#!/bin/bash
function sync {
	rsync --progress --delete-after --dirs --times jenkins@download.osmand.net:$1 $1
}
sync /var/www-download/indexes/
sync /var/www-download/road-indexes/

