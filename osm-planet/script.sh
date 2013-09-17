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
		echo "Skipping $3 country from $1 $(date) ...";
	else
		echo "Extracting $3 country from $1 $(date) ..."
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
      generate $1 ${FOLDER} ${FILENAME::-5}
  done
}

#sorted according to regions list in osmand-tools.
# 1. AFRICA
convert $PLANET_FILE "polygons/" "africa"

#borders ok
convertFolder "$EXTRACT_DIR"/africa.pbf "polygons/africa/"

# 2. Asia
# 2.1 east asia
#still work to be done, maybe put all in one regiona asia, and use smaller region in asia.poly file or just revise regions east&ocean boundary
convert $PLANET_FILE "polygons/" "east-asia"
convertFolder "$EXTRACT_DIR"/east-asia.pbf "polygons/east-asia/"

# 2.1 ocean asia
convert $PLANET_FILE "polygons/" "ocean-asia"
convertFolder "$EXTRACT_DIR"/ocean-asia.pbf "polygons/ocean-asia/"

#4. Central America
convert $PLANET_FILE "polygons/" "central-america"
convertFolder "$EXTRACT_DIR"/central-america.pbf  "polygons/central-america" 
convertFolder "$EXTRACT_DIR"/central-america.pbf  "polygons/north-america" 

#5. Russia
convert $PLANET_FILE "polygons/" "russia"
convertFolder "$EXTRACT_DIR"/russia.pbf  "polygons/russia/" "russia"

#6. Europe
convert $PLANET_FILE "polygons/" "europe"
convertFolder "$EXTRACT_DIR"/europe.pbf  "polygons/europe" 

# 7. South America
convert $PLANET_FILE "polygons/" "south-america"
convertFolder "$EXTRACT_DIR"/south-america.pbf  "polygons/south-america" 

# 8. Oceania and Australia
convert $PLANET_FILE "polygons/" "australia-oceania"
convertFolder "$EXTRACT_DIR"/australia-oceania.pbf "polygons/australia-oceania"
