#!/bin/bash -xe

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
TARGETDIR=/home/osm-planet/osm-extract

pbf2o5m() {
	echo Converting $1 to o5m
	time osmconvert $TARGETDIR/$1.pbf --out-o5m > $TARGETDIR/$1.o5m
	if [[ $? != 0 ]]; then
		echo Error
	else 
		rm $TARGETDIR/$1.pbf
	fi
	TZ=UTC touch -c -d "$(date +%Y-%m)-01" $TARGETDIR/$1.o5m
}


osmium_extract() {
	echo Extracting from $1.json to $TARGETDIR/$1.$2
	time osmium extract -c "$DIR/$1.json" -s smart -S types=multipolygon --overwrite $TARGETDIR/$1.$2
}

# osmium_extract planet-latest o5m
# osmium_extract europe pbf
# osmium_extract north-america pbf


pbf2o5m europe
pbf2o5m north-america
pbf2o5m asia
pbf2o5m west-europe
pbf2o5m us
pbf2o5m africa
pbf2o5m ocean-asia
pbf2o5m south-europe
pbf2o5m east-europe
pbf2o5m east-asia
pbf2o5m russia
pbf2o5m france
pbf2o5m germany
pbf2o5m south-america
pbf2o5m north-europe
pbf2o5m us-northeast
pbf2o5m us-west
pbf2o5m canada
pbf2o5m us-south
pbf2o5m us-northcentral
pbf2o5m great-britain
pbf2o5m australia-oceania-all
pbf2o5m central-america
pbf2o5m antarctica
