#!/bin/bash
# Takes 2 arguments planet.obf file and folder with extracts
EXTRACT_DIR=$2
PLANET_FILE=$1
if [ -z "$EXTRACT_DIR" ]; then
	EXTRACT_DIR=extracted
fi
mkdir -p "$EXTRACT_DIR"

function convert {
	for i in $1
	do
		echo "Extracting $i country from $2 $(date) ..."
		time osmconvert $2 -B=$3/$i.poly --complex-ways --complete-ways --drop-author -o="$EXTRACT_DIR"/$i.pbf
	done;
}

# 1. AMERICAS
AMERICAS=""
#South America
AMERICAS+="guyana""paraguay""peru""suriname""venezuela" 
#_NorthAmerica
AMERICAS+=" bermuda greenland"
# Central America
AMERICAS+=" costa_rica el_salvador honduras nicaragua panama"
# Carribean (suffix = _CentralAmerica)
AMERICAS+=" anguilla antigua_and_barbuda aruba 
          bahamas barbados british_virgin_islands 
          cayman_islands cuba dominica dominican_republic 
          haiti jamaica grenada guadeloupe martinique 
          montserrat netherlands_antilles puerto_rico  
          saint_vincent_and_the_grenadines trinidad_and_tobago virgin_islands_us"

# convert $AMERICAS "$PLANET_FILE" "polygons/americas/"

# 2. AFRICA Geofabrik
convert "africa" $PLANET_FILE "geo-polygons/"
AFRICA_GEOFABRIK="burkina_faso canary_islands ethiopia guinea guinea-bissau ivory_coast 
				liberia libya madagascar morocco nigeria somalia south_africa_and_lesotho tanzania "
convert $AFRICA_GEOFABRIK "$EXTRACT_DIR"/africa.pbf "geo-polygons/africa/"

# 3. ASIA
ASIA="";
ASIA+=" hong_kong macao north_korea south_korea"
ASIA+=" brunei cambodia christmas_island east_timor laos malaysia myanmar singapore spratly_islands thailand vietnam"
ASIA+=" afghanistan bangladesh bhutan british_indian_ocean_territory iran maldives nepal sri_lanka"
ASIA+=" armenia bahrain caspian_sea cyprus georgia jordan kuwait lebanon oman qatar saudi_arabia syria turkey united_arab_emirates yemen"

convert "asia" $PLANET_FILE "geo-polygons/"
convert $ASIA  "$EXTRACT_DIR"/asia.pbf "polygons/asia/"


