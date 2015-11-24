#!/bin/bash
function sync {
	rsync --progress --delete-after -a --dirs --times jenkins@download.osmand.net:$1 $1
}
sync /var/www-download/indexes/
sync /var/www-download/wiki/
#sync /var/www-download/road-indexes/

