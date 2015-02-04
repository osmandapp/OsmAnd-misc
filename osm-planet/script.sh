#!/bin/bash
# Takes 2 arguments planet.obf file and folder with extracts
EXTRACT_DIR=$2
PLANET_FILE=$1
if [ -z "$EXTRACT_DIR" ]; then
	EXTRACT_DIR=extracted
fi
mkdir -p "$EXTRACT_DIR"

generate()  {
	FILE="$EXTRACT_DIR"/$3.pbf
	if [ ! -z $4 ]; then
		FILE="$EXTRACT_DIR"/$4-$3.pbf
	fi
	if [[ ! -s $FILE ]] ; then 
		if [ -f $FILE ]; then rm $FILE; 
		fi
	fi
	if [ -f $FILE ]; then
		echo "Skipping $FILE country from $1 $(date) ...";
	else
		echo "Extracting $FILE country from $1 $(date) ..."
		time osmconvert $1 -B=$2/$3.poly --complex-ways --complete-ways --drop-author -o=$FILE
	fi
}

convert() {
	for i in  ${@:3} 
	do
		generate $1 $2 $3
	done;
}

convertFolder() {
  SOURCE_PBF=$1
  FOLDER=$2
  for FILE in ${FOLDER}/*.poly; do
      FILENAME=${FILE##*/}
      if [[ $FILENAME == _* ]]; then
        continue;
      fi
      generate $1 ${FOLDER} ${FILENAME::-5} $3
  done
}

#sorted according to regions list in osmand-tools.
# 1. AFRICA
convert $PLANET_FILE "polygons/" "africa"

#borders ok
convertFolder "$EXTRACT_DIR"/africa.pbf "polygons/africa/"

# 2. Asia
convert $PLANET_FILE "polygons/" "asia"

# 2.1 east asia
#still work to be done, maybe put all in one regiona asia, and use smaller region in asia.poly file or just revise regions east&ocean boundary
convert $PLANET_FILE "polygons/" "east-asia"
convertFolder "$EXTRACT_DIR"/east-asia.pbf "polygons/east-asia/"
convertFolder "$EXTRACT_DIR"/india.pbf  "polygons/east-asia/india-regions" "India"

# 2.1 ocean asia
convert $PLANET_FILE "polygons/" "ocean-asia"
convertFolder "$EXTRACT_DIR"/ocean-asia.pbf "polygons/ocean-asia/"
convertFolder "$EXTRACT_DIR"/ocean-asia.pbf "polygons/ocean-asia/japan-regions" "Japan"

#4. Central America
convert $PLANET_FILE "polygons/" "central-america"
convertFolder "$EXTRACT_DIR"/central-america.pbf  "polygons/central-america"
convertFolder "$EXTRACT_DIR"/central-america.pbf  "polygons/north-america"

#5. Russia
convert $PLANET_FILE "polygons/" "russia"
convertFolder "$EXTRACT_DIR"/russia.pbf  "polygons/russia/" "russia"
convertFolder "$EXTRACT_DIR"/russia.pbf  "polygons/russia-regions/" "russia"

#6. Europe
convert $PLANET_FILE "polygons/" "europe"
convertFolder "$EXTRACT_DIR"/europe.pbf  "polygons/europe"
convertFolder "$EXTRACT_DIR"/europe.pbf  "polygons/europe/additional"
convertFolder "$EXTRACT_DIR"/british-isles.pbf  "polygons/europe/gb-regions" "gb_england"
convertFolder "$EXTRACT_DIR"/british-isles.pbf  "polygons/europe/gb-shires"
# convertFolder "$EXTRACT_DIR"/italy.pbf  "polygons/europe/italy-regions" "Italy"
# convertFolder "$EXTRACT_DIR"/spain.pbf  "polygons/europe/spain-regions" "Spain"

#6.1. North Europe
convert $PLANET_FILE "polygons/" "north-europe"
convertFolder "$EXTRACT_DIR"/north-europe.pbf  "polygons/north-europe"

#6.2. East Europe
convert $PLANET_FILE "polygons/" "east-europe"
convertFolder "$EXTRACT_DIR"/east-europe.pbf  "polygons/east-europe"

#6.3. South Europe
convert $PLANET_FILE "polygons/" "south-europe"
convertFolder "$EXTRACT_DIR"/south-europe.pbf  "polygons/south-europe"
convertFolder "$EXTRACT_DIR"/south-europe.pbf  "polygons/south-europe/additional"
convertFolder "$EXTRACT_DIR"/spain.pbf  "polygons/south-europe/spain-regions" "Spain"
convertFolder "$EXTRACT_DIR"/italy.pbf  "polygons/south-europe/italy-regions" "Italy"

#6.4. West Europe
#convert $PLANET_FILE "polygons/" "west-europe"
#convertFolder "$EXTRACT_DIR"/west-europe.pbf  "polygons/west-europe/additional"
#convertFolder "$EXTRACT_DIR"/france.pbf  "polygons/west-europe/france-regions" "France"
#convertFolder "$EXTRACT_DIR"/germany.pbf  "polygons/west-europe/germany-regions" "Germany"
#convertFolder "$EXTRACT_DIR"/netherlands.pbf  "polygons/west-europe/netherlands-regions" "Netherlands"
#convertFolder "$EXTRACT_DIR"/great-britain.pbf  "polygons/west-europe/gb-regions" "gb_england"


# 7. South America
convert $PLANET_FILE "polygons/" "south-america"
convertFolder "$EXTRACT_DIR"/south-america.pbf  "polygons/south-america"

# 8. Oceania and Australia
convert $PLANET_FILE "polygons/" "australia-oceania"
convertFolder "$EXTRACT_DIR"/australia-oceania.pbf "polygons/australia-oceania"

# 8. USA and Canada
convert $PLANET_FILE "polygons/" "north-america"
convert "$EXTRACT_DIR"/north-america.pbf "polygons/" "canada"
