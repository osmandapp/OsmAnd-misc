#!/bin/bash
# Takes 2 arguments planet.obf file and folder with extracts
EXTRACT_DIR=$2
PLANET_FILE=$1
if [ -z "$EXTRACT_DIR" ]; then
	EXTRACT_DIR=extracted
fi
mkdir -p "$EXTRACT_DIR"

function convert {
	for i in  ${@:3} 
	do
		FILE="$EXTRACT_DIR"/$i.pbf
		if [[ ! -s $FILE ]] ; then 
			if [ -f $FILE ]; then rm $FILE; 
			fi
		fi
		if [ -f $FILE ]; then
			echo "Skipping $i country from $1 $(date) ...";
		else
			echo "Extracting $i country from $1 $(date) ..."
			time osmconvert $1 -B=$2/$i.poly --complex-ways --complete-ways --drop-author -o=$FILE
		fi
	done;
}

#sorted according to regions list in osmand-tools.
#Geofabrik is not neded because those extracts are already processed.
# 1. AFRICA
convert $PLANET_FILE "polygons/" "africa"

#borders ok
AFRICA="burundi chad kenya mauritania"
convert "$EXTRACT_DIR"/africa.pbf "polygons/africa/" $AFRICA

#need to fix borders...
AFRICA2="mali"
convert "$EXTRACT_DIR"/africa.pbf "polygons/africa/" $AFRICA2

# 2. Asia
# 2.1 east asia
#still work to be done, maybe put all in one regiona asia, and use smaller region in asia.poly file or just revise regions east&ocean boundary
convert $PLANET_FILE "polygons/" "east-asia"

#borders ok
EAST_ASIA="british-indian-ocean-territory maldives sri-lanka"
convert "$EXTRACT_DIR"/east-asia.pbf "polygons/east-asia/" $EAST_ASIA

#need to fix borders...
EAST_ASIA2="afghanistan armenia bahrain bhutan georgia iran jordan kuwait lebanon nepal oman qatar saudi-arabia syria united-arab-emirates yemen"
convert "$EXTRACT_DIR"/east-asia.pbf "polygons/east-asia/" $EAST_ASIA2

# 2.1 ocean asia
convert $PLANET_FILE "polygons/" "ocean-asia"

#borders ok
OCEAN_ASIA="christmas-island spratly-islands"
convert "$EXTRACT_DIR"/ocean-asia.pbf "polygons/ocean-asia/" $OCEAN_ASIA

#need to fix borders...
OCEAN_ASIA2="bangladesh brunei cambodia east-timor hong-kong laos macao malaysia myanmar north-korea singapore south-korea vietnam"
convert "$EXTRACT_DIR"/ocean-asia.pbf "polygons/ocean-asia/" $OCEAN_ASIA2

#4. Central America
convert $PLANET_FILE "polygons/" "central-america"

#borders ok
CENTRAL_AMERICA="anguilla antigua-and-barbuda aruba bahamas barbados cayman-islands costa-rica cuba el-salvador honduras jamaica guadeloupe martinique montserrat panama puerto-rico saint-vincent-and-the-grenadines trinidad-and-tobago virgin-islands-british virgin-islands-us" 
convert "$EXTRACT_DIR"/central-america.pbf  "polygons/central-america" $CENTRAL_AMERICA

#need to fix borders...
CENTRAL_AMERICA2="dominica grenada netherlands-antilles nicaragua" 
convert "$EXTRACT_DIR"/central-america.pbf  "polygons/central-america" $CENTRAL_AMERICA2

#5. Europe
convert $PLANET_FILE "polygons/" "europe"
# borders fixed
EUROPE="portugal switzerland" 
convert "$EXTRACT_DIR"/europe.pbf  "polygons/europe" $EUROPE

#6. North America
#borders ok
NORTH_AMERICA="bermuda greenland"
convert "$EXTRACT_DIR"/central-america.pbf  "polygons/north-america" $NORTH_AMERICA


# 7. South America
convert $PLANET_FILE "polygons/" "south-america"

#need to fix borders...
SOUTH_AMERICA="guyana paraguay peru suriname venezuela" 
convert "$EXTRACT_DIR"/south-america.pbf  "polygons/south-america" $SOUTH_AMERICA
