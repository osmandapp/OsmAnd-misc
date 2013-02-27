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
		if [[ -s $FILE ]] ; then rm $FILE; 
		fi
		if [ -f $FILE ]; then
			echo "Skipping $i country from $1 $(date) ...";
		else
			echo "Extracting $i country from $1 $(date) ..."
			time osmconvert $1 -B=$2/$i.poly --complex-ways --complete-ways --drop-author -o=$FILE
		fi
	done;
}

# 1. AMERICAS
AMERICAS=""
#South America
SOUTH_AMERICA="guyana paraguay peru suriname venezuela" 
convert $PLANET_FILE "geo-polygons/" "south-america"
convert "$EXTRACT_DIR"/south-america.pbf  "polygons/americas" $SOUTH_AMERICA

#NorthAmerica
NORTH_AMERICA=" bermuda greenland"
# TODO north america too big for 2 small countries
#convert $PLANET_FILE "geo-polygons/" "north-america"
#convert "$EXTRACT_DIR"/north-america.pbf  "polygons/americas" $NORTH_AMERICA


# Central America
convert $PLANET_FILE "geo-polygons/" "central-america"

CENTRAL_AMERICA=" costa_rica el_salvador honduras nicaragua panama"
convert "$EXTRACT_DIR"/central-america.pbf  "polygons/americas" $CENTRAL_AMERICA

# Carribean (suffix = _CentralAmerica)
CARRIBEAN=" anguilla antigua_and_barbuda aruba 
          bahamas barbados british_virgin_islands 
          cayman_islands cuba dominica dominican_republic 
          haiti jamaica grenada guadeloupe martinique 
          montserrat netherlands_antilles puerto_rico  
          saint_vincent_and_the_grenadines trinidad_and_tobago virgin_islands_us"
convert "$EXTRACT_DIR"/central-america.pbf  "polygons/americas" $CARRIBEAN

# 2. AFRICA Geofabrik
convert $PLANET_FILE "geo-polygons/" "africa"
AFRICA_GEOFABRIK="burkina_faso canary_islands ethiopia guinea guinea-bissau ivory_coast 
				liberia libya madagascar morocco nigeria somalia south_africa_and_lesotho tanzania "
convert "$EXTRACT_DIR"/africa.pbf "geo-polygons/africa/" $AFRICA_GEOFABRIK

# 3. ASIA
ASIA="";
ASIA+=" hong_kong macao north_korea south_korea"
ASIA+=" brunei cambodia christmas_island east_timor laos malaysia myanmar singapore spratly_islands thailand vietnam"
ASIA+=" afghanistan bangladesh bhutan british_indian_ocean_territory iran maldives nepal sri_lanka"
ASIA+=" armenia bahrain cyprus georgia jordan kuwait lebanon oman qatar saudi_arabia syria united_arab_emirates yemen"

convert $PLANET_FILE "geo-polygons/" "asia"
convert "$EXTRACT_DIR"/asia.pbf "polygons/asia/" $ASIA


