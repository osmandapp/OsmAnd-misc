#!/bin/bash
function sync {
	rsync --progress --delete-after -g --dirs --times jenkins@download.osmand.net:$1 $1
}
sync /var/www-download/indexes/
#sync /var/www-download/road-indexes/
#sync /var/www-download/wiki/
