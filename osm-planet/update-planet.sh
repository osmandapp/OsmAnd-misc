#!/bin/bash -xe
#This script updates planet using OSC
PLANET_FULL_PATH=/home/osm-planet/planet-latest.o5m
PLANET_FULL_PATH_BACKUP=/home/osm-planet/planet-latest.o5m_backup
TIGER_FULL_PATH=/home/osm-planet/tiger.o5m

PLANET_DIR=$(dirname $PLANET_FULL_PATH)
PLANET_FILENAME=$(basename $PLANET_FULL_PATH)
PLANET_FILENAME=${PLANET_FILENAME%%.*}

if [ -f $PLANET_FULL_PATH_BACKUP ]; then
	echo Restore original planet OSM from backup
	rm $PLANET_FULL_PATH
	cp $PLANET_FULL_PATH_BACKUP $PLANET_FULL_PATH
fi

echo Processing $PLANET_FULL_PATH
echo Getting planet timestamp...
REAL_PLANET_TIMESTAMP=$(osmconvert --out-statistics $PLANET_FULL_PATH | grep "timestamp max:" | sed 's/timestamp max: //g')
#REAL_PLANET_TIMESTAMP="2023-07-31T23:59:09Z" # FOR HOTFIXES
echo Planet timestamp max: $REAL_PLANET_TIMESTAMP

FIRST_DAY_TIMESTAMP=$(date +%Y-%m)-01
OS=$(uname)
MIN_DATE="2023-01-01"
PLANET_TIMESTAMP=""
if [ "$OS" = "Darwin" ]; then
	MIN_DATE=$(date -j -v-3m +"%Y-%m")-01
	PLANET_TIMESTAMP=$(date -j -v +10M -f "%Y-%m-%dT%H:%M:%SZ" "$REAL_PLANET_TIMESTAMP" +"%Y-%m-%d")
fi
if [ "$OS" = "Linux" ]; then
	MIN_DATE=$(date --date="3 month ago" +"%Y-%m")-01
	PLANET_TIMESTAMP=$(date -d "$REAL_PLANET_TIMESTAMP + 10 minutes" +"%Y-%m-%d")
fi

if [ "$PLANET_TIMESTAMP" = "$FIRST_DAY_TIMESTAMP" ]; then
	echo "Planet already updated on date $REAL_PLANET_TIMESTAMP"
	exit 0
fi

if [ "$PLANET_TIMESTAMP" = "${REAL_PLANET_TIMESTAMP:0:10}" ]; then
	echo "Process newly downloaded planet file"
fi

if [[ -d "listing_tmp" ]] ; then rm listing_tmp/* || true; fi
if [[ ! -d "listing_tmp" ]] ; then mkdir listing_tmp; fi
#if [[ -d "osc_tmp" ]] ; then rm osc_tmp/* || true; fi
if [[ ! -d "osc_tmp" ]] ; then mkdir osc_tmp; fi

LISTING_FILE=listing_tmp/file_list.txt
SORTED_FILE=listing_tmp/sorted_list.txt
URL="https://planet.openstreetmap.org/replication/day/000/"
echo Getting file list from $URL
DAY_DIRS=( $(wget -qO- $URL | grep '\[DIR\]' | sed -e 's/<[^>]*>//g' | awk '{print $1}' ) )
for dir in "${DAY_DIRS[@]}"
do
   : 
   echo -e "Collect files in $URL$dir"
   wget -qO- $URL$dir | sed -e 's/<[^>]*>//g' | grep txt | awk -v url=$URL -v dir="$dir" '{print url dir $1" "$2}' >> $LISTING_FILE
done

sort -r $LISTING_FILE -o $SORTED_FILE

DOWNLOAD=false
MERGE_FILES=""
while IFS= read -r line
do
	DATE=${line: -10}
	FILE=$(awk '{print $1}' <<< $line)
	FILE="${FILE/.state.txt/.osc.gz}"
	if [ "$DATE" = "$FIRST_DAY_TIMESTAMP" ]; then
		DOWNLOAD=true
   	fi
	if [ "$DATE" = "$PLANET_TIMESTAMP" ]; then
		DOWNLOAD=false
	fi
	FILE_NAME=${FILE: -10}
	if $DOWNLOAD; then
 		MERGE_FILES="osc_tmp/$FILE_NAME $MERGE_FILES"
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
	if [ "$DATE" = "$MIN_DATE" ]; then
		break
	fi
done < "$SORTED_FILE"

COUNT_OSC_FILES=$(ls osc_tmp | wc -l)
if [ "$(($COUNT_OSC_FILES + 0))" = "0" ]; then
	echo "No *.osc.gz files for update planet"
	exit 1
fi

echo Merging OSC...
time osmconvert -v --merge-versions $MERGE_FILES --out-o5c > "osc_tmp/update.o5c"
echo Applying OSC...
time osmconvert -v $PLANET_FULL_PATH osc_tmp/update.o5c --timestamp=$(echo $FIRST_DAY_TIMESTAMP) --out-o5m > "$PLANET_DIR/$PLANET_FILENAME.o5mtmp"
if [[ $? != 0 ]] ; then
	echo Error applying OSC... 
	exit 1
else
	mv -f "$PLANET_DIR/$PLANET_FILENAME.o5mtmp" "$PLANET_DIR/$PLANET_FILENAME.o5m"
	
	# Backup
	echo Copying planet...
	cp $PLANET_FULL_PATH $PLANET_FULL_PATH_BACKUP

	# Tiger
	if [ -f $TIGER_FULL_PATH ]; then
		time osmconvert $TIGER_FULL_PATH $PLANET_FULL_PATH -o=planet_with_tiger.o5m
		if [[ $? != 0 ]] ; then
			echo Error adding Tiger... 
			exit 1
		else
			rm $PLANET_FULL_PATH
			mv planet_with_tiger.o5m $PLANET_FULL_PATH
			echo Successfully added Tiger file $TIGER_FULL_PATH to $PLANET_FULL_PATH
		fi	
	fi
# 	echo Setting timestamp...
# 	NEW_PLANET_TIMESTAMP=$(osmconvert $PLANET_DIR/$PLANET_FILENAME.o5m --out-statistics | grep "timestamp max" | sed 's/timestamp max: //g')
# 	osmconvert --timestamp=$(echo $NEW_PLANET_TIMESTAMP) $PLANET_DIR/$PLANET_FILENAME.o5m --out-o5m > "$PLANET_DIR/$PLANET_FILENAME.o5mtmp"
# 	mv -f "$PLANET_DIR/$PLANET_FILENAME.o5mtmp" $PLANET_FULL_PATH
	TZ=UTC touch -c -d "$FIRST_DAY_TIMESTAMP" $PLANET_DIR/$PLANET_FILENAME.o5m
	echo Planet ${PLANET_DIR}/${PLANET_FILENAME}.o5m updated to $FIRST_DAY_TIMESTAMP
	rm osc_tmp/*
	rm listing_tmp/*
fi
