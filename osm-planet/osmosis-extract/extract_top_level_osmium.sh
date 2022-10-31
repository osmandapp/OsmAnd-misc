#!/bin/bash
pbf2o5m() {
	echo Converting $1 to o5m
	time osmconvert $1.pbf --out-o5m > $1.o5m
	if [[ $? != 0 ]]; then
		echo Error
	else rm $1.pbf
	fi
	TZ=UTC touch -c -d "$(date +%Y-%m)-01" $1.o5m
}
DIR=/mnt/home-ssd/osm-planet

osmium_extract() {
	echo Extracting $1 $2 $3
	time osmium extract -c $1.json -s smart -S types=multipolygon --overwrite $2/$1.$3
	TZ=UTC touch -c -d "$(date +%Y-%m)-01" $1.pbf
}

osmium_extract planet-latest $DIR o5m
osmium_extract europe $DIR pbf
osmium_extract west-europe $DIR pbf
osmium_extract asia $DIR pbf
osmium_extract north-america $DIR pbf
osmium_extract us $DIR pbf
osmium_extract australia-oceania-all $DIR pbf

# time osmium extract -c planet-latest.json -s smart -S types=multipolygon $DIR/planet-latest.o5m
# time osmium extract -c europe.json -s smart -S types=multipolygon $DIR/europe.pbf
# time osmium extract -c west-europe.json -s smart -S types=multipolygon $DIR/west-europe.pbf
# time osmium extract -c asia.json -s smart -S types=multipolygon $DIR/asia.pbf
# time osmium extract -c north-america.json -s smart -S types=multipolygon $DIR/north-america.pbf
# time osmium extract -c us.json -s smart -S types=multipolygon $DIR/us.pbf
# time osmium extract -c australia-oceania-all.json -s smart -S types=multipolygon $DIR/australia-oceania-all.pbf

# time osmconvert --complex-ways --complete-ways australia-oceania-all.o5m -B=australia-oceania.poly -o=australia-oceania-osmconvert.pbf

pbf2o5m europe
pbf2o5m north-america
pbf2o5m asia
pbf2o5m west-europe
pbf2o5m us
pbf2o5m europe-highway
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
pbf2o5m europe-highway-tertiary
pbf2o5m australia-oceania-all
pbf2o5m central-america
pbf2o5m antarctica