#!/bin/bash -xe
#This script updates planet using OSC
PLANET_FULL_PATH=/home/osm-planet/planet-latest.o5m

PLANET_DIR=$(dirname $PLANET_FULL_PATH)
PLANET_FILENAME=$(basename $PLANET_FULL_PATH)
PLANET_FILENAME=${PLANET_FILENAME%%.*}

echo Processing $PLANET_FULL_PATH
echo Getting planet timestamp...
PLANET_TIMESTAMP=$(osmconvert --out-statistics $PLANET_FULL_PATH | grep "timestamp max:" | sed 's/timestamp max: //g')
#echo Planet timestamp max: $PLANET_TIMESTAMP
PLANET_TIMESTAMP=${PLANET_TIMESTAMP:0:10}
# PLANET_TIMESTAMP="2020-11-29" # FOR HOTFIXES

FIRST_DAY_TIMESTAMP=$(date +%Y-%m)-01
OS=$(uname)
MIN_DATE="2023-01-01"
if [ "$OS" = "Darwin" ]; then
	MIN_DATE=$(date -j -v-3m +"%Y-%m")-01
fi
if [ "$OS" = "Linux" ]; then
	MIN_DATE=$(date --date="3 month ago" +"%Y-%m")-01
fi

if [[ -d "listing_tmp" ]] ; then rm listing_tmp/* || true; fi
if [[ ! -d "listing_tmp" ]] ; then mkdir listing_tmp; fi
#if [[ -d "osc_tmp" ]] ; then rm osc_tmp/* || true; fi
if [[ ! -d "osc_tmp" ]] ; then mkdir osc_tmp; fi

LISTING_FILE=listing_tmp/file_list.txt
URL="https://planet.openstreetmap.org/replication/day/000/"
echo Getting file list from $URL
DAY_DIRS=( $(wget -qO- $URL | grep '\[DIR\]' | sed -e 's/<[^>]*>//g' | awk '{print $1}' ) )
for dir in "${DAY_DIRS[@]}"
do
   : 
   echo -e "Collect files in $URL$dir"
   wget -qO- $URL$dir | sed -e 's/<[^>]*>//g' | grep txt | awk -v url=$URL -v dir="$dir" '{print url dir $1" "$2}' >> $LISTING_FILE
done

DOWNLOAD=false
while IFS= read -r line
do
	DATE=${line: -10}
	FILE=$(awk '{print $1}' <<< $line)
	FILE="${FILE/.state.txt/.osc.gz}"
	if [ "$DATE" = "$FIRST_DAY_TIMESTAMP" ]; then
		DOWNLOAD=true
   	fi
	FILE_NAME=${FILE: -10}
	if $DOWNLOAD; then		
		if [ -f "osc_tmp/$FILE_NAME" ]; then
			echo ">>>> File exist $FILE_NAME for date $DATE"
		else 
			echo ">>>> Download $FILE for date $DATE"
			wget -q --directory-prefix=osc_tmp/ -nc -c $FILE
		fi
	else
		if [ -f "osc_tmp/$FILE_NAME" ]; then
			echo ">>>> Remove $FILE_NAME for date $DATE"
			rm osc_tmp/$FILE_NAME
		fi
	fi
	if [ "$DATE" = "$PLANET_TIMESTAMP" ]; then
		DOWNLOAD=false
	fi
	if [ "$DATE" = "$MIN_DATE" ]; then
		break
	fi
done < "$LISTING_FILE"

echo Copying planet...
cp -f $PLANET_FULL_PATH ${PLANET_FULL_PATH}_bak
echo Merging OSC...
time osmconvert -v --merge-versions osc_tmp/*.osc.gz --out-o5c > "osc_tmp/update.o5c"
echo Applying OSC...
time osmconvert -v $PLANET_FULL_PATH osc_tmp/update.o5c --timestamp=$(echo $FIRST_DAY_TIMESTAMP) --out-o5m > "$PLANET_DIR/$PLANET_FILENAME.o5mtmp"
if [[ $? != 0 ]] ; then
	echo Error applying OSC... 
	exit 1
else
	mv -f "$PLANET_DIR/$PLANET_FILENAME.o5mtmp" "$PLANET_DIR/$PLANET_FILENAME.o5m"
# 	echo Setting timestamp...
# 	NEW_PLANET_TIMESTAMP=$(osmconvert $PLANET_DIR/$PLANET_FILENAME.o5m --out-statistics | grep "timestamp max" | sed 's/timestamp max: //g')
# 	osmconvert --timestamp=$(echo $NEW_PLANET_TIMESTAMP) $PLANET_DIR/$PLANET_FILENAME.o5m --out-o5m > "$PLANET_DIR/$PLANET_FILENAME.o5mtmp"
# 	mv -f "$PLANET_DIR/$PLANET_FILENAME.o5mtmp" $PLANET_FULL_PATH
	TZ=UTC touch -c -d "$FIRST_DAY_TIMESTAMP" $PLANET_DIR/$PLANET_FILENAME.o5m
	echo Planet ${PLANET_DIR}/${PLANET_FILENAME}.o5m updated to $FIRST_DAY_TIMESTAMP
	rm osc_tmp/*
	rm listing_tmp/*
fi
