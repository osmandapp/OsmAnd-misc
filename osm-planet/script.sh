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

#need to fix borders...
AFRICA="mali"
convert "$EXTRACT_DIR"/africa.pbf "polygons/africa/" $AFRICA

# 2. Asia
# 2.1 east asia
#still work to be done
convert $PLANET_FILE "polygons/" "east-asia"

#need to fix borders...
EAST_ASIA="afghanistan armenia bahrain british-indian-ocean-territory bhutan georgia iran jordan kuwait lebanon maldives nepal oman qatar saudi-arabia sri-lanka syria united-arab-emirates yemen"
convert "$EXTRACT_DIR"/east-asia.pbf "polygons/north-asia/" $EAST_ASIA

# 2.1 ocean asia
convert $PLANET_FILE "polygons/" "ocean-asia"

#need to fix borders...
OCEAN_ASIA="bangladesh brunei cambodia christmas-island east-timor hong-kong laos macao malaysia myanmar north-korea singapore south-korea spratly-islands vietnam"
convert "$EXTRACT_DIR"/ocean-asia.pbf "polygons/ocean-asia/" $NORTH_ASIA

#4. Central America
convert $PLANET_FILE "polygons/" "central-america"

#borders ok... check later
CENTRAL_AMERICA="aruba bahamas barbados cayman-islands cuba jamaica" 
convert "$EXTRACT_DIR"/central-america.pbf  "polygons/central-america" $CENTRAL_AMERICA

#need to fix borders...
CENTRAL_AMERICA2="anguilla antigua-and-barbuda  
          costa-rica dominica el-salvador
          grenada guadeloupe honduras martinique 
          montserrat netherlands-antilles nicaragua panama puerto-rico  
          saint-vincent-and-the-grenadines trinidad-and-tobago virgin-islands-british virgin-islands-us" 
convert "$EXTRACT_DIR"/central-america.pbf  "polygons/central-america" $CENTRAL_AMERICA2

#5. Europe
#all present, i think so, but for numbering purposes

#6. North America
#borders ok
NORTH_AMERICA="bermuda greenland"
convert "$EXTRACT_DIR"/central-america.pbf  "polygons/north-america" $NORTH_AMERICA


# 7. South America
convert $PLANET_FILE "polygons/" "south-america"

#need to fix borders...
SOUTH_AMERICA="guyana paraguay peru suriname venezuela" 
convert "$EXTRACT_DIR"/south-america.pbf  "polygons/south-america" $SOUTH_AMERICA