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

# 1. AMERICAS
AMERICAS=""
#South America
SOUTH_AMERICA="guyana paraguay peru suriname venezuela" 
convert $PLANET_FILE "polygons/" "south-america"
convert "$EXTRACT_DIR"/south-america.pbf  "polygons/south-america" $SOUTH_AMERICA

#NorthAmerica
#NORTH_AMERICA=" bermuda greenland"
# TODO north america too big for 2 small countries
#convert $PLANET_FILE "geo-polygons/" "north-america"
#convert "$EXTRACT_DIR"/north-america.pbf  "polygons/americas" $NORTH_AMERICA


# Central America
convert $PLANET_FILE "polygons/" "central-america"

CENTRAL_AMERICA=" costa_rica el_salvador honduras nicaragua panama puerto_rico trinidad_and_tobago bermuda greenland"
convert "$EXTRACT_DIR"/central-america.pbf  "polygons/central-america" $CENTRAL_AMERICA

# Carribean (suffix = _CentralAmerica)
CARRIBEAN=" anguilla antigua_and_barbuda aruba 
          bahamas barbados british_virgin_islands 
          cayman_islands cuba dominica dominican_republic
          grenada guadeloupe haiti jamaica martinique 
          montserrat netherlands_antilles   
          saint_vincent_and_the_grenadines virgin_islands_us"
convert "$EXTRACT_DIR"/central-america.pbf  "polygons/central-america" $CARRIBEAN

# 2. AFRICA Geofabrik
convert $PLANET_FILE "polygons/" "africa"
AFRICA_GEOFABRIK="burkina_faso canary_islands ethiopia guinea guinea-bissau ivory_coast 
				liberia libya madagascar morocco nigeria somalia south_africa_and_lesotho tanzania "
convert "$EXTRACT_DIR"/africa.pbf "geo-polygons/africa/" $AFRICA_GEOFABRIK
AFRICA="mali dr_congo"
convert "$EXTRACT_DIR"/africa.pbf "polygons/africa/" $AFRICA

# 3. ASIA
#ASIA="";
#ASIA+=" hong_kong macao north_korea south_korea"
#ASIA+=" brunei cambodia christmas_island east_timor laos malaysia myanmar singapore spratly_islands thailand vietnam"
#ASIA+=" afghanistan bangladesh bhutan british_indian_ocean_territory iran maldives nepal sri_lanka"
#ASIA+=" armenia bahrain cyprus georgia jordan kuwait lebanon oman qatar saudi_arabia syria united_arab_emirates yemen"

convert $PLANET_FILE "polygons/" "north-asia"
NORTH_ASIA="bhutan hong_kong macao north_korea south_korea"
convert "$EXTRACT_DIR"/north-asia.pbf "polygons/north-asia/" $NORTH_ASIA

convert $PLANET_FILE "polygons/" "east-asia"
EAST_ASIA="afghanistan armenia bahrain british_indian_ocean_territory georgia iran jordan kuwait lebanon maldives nepal oman qatar saudi_arabia sri_lanka syria united_arab_emirates yemen"
convert "$EXTRACT_DIR"/east-asia.pbf "polygons/north-asia/" $EAST_ASIA

convert $PLANET_FILE "polygons/" "ocean-asia"
OCEAN_ASIA="bangladesh brunei cambodia christmas_island east_timor laos malaysia myanmar singapore spratly_islands thailand vietnam"
convert "$EXTRACT_DIR"/ocean-asia.pbf "polygons/ocean-asia/" $NORTH_ASIA