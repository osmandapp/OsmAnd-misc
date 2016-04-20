#!/bin/bash
#This script updates planet using OSC
PLANET_FULL_PATH=/home/osm-planet/planet-latest.o5m

PLANET_DIR=$(dirname $PLANET_FULL_PATH)
PLANET_FILENAME=$(basename $PLANET_FULL_PATH)
PLANET_FILENAME=${PLANET_FILENAME%%.*}

echo Processing $PLANET_FULL_PATH
echo Getting planet timestamp...
PLANET_TIMESTAMP=$(osmconvert --out-statistics $PLANET_FULL_PATH | grep "timestamp max:" | sed 's/timestamp max: //g')
echo Planet timestamp max: $PLANET_TIMESTAMP
PLANET_TIMESTAMP=${PLANET_TIMESTAMP:0:10}
FIRST_DAY_TIMESTAMP=$(date +%Y-%m)-01

if [[ -d "listing_tmp" ]] ; then rm listing_tmp/* ; fi
if [[ ! -d "listing_tmp" ]] ; then mkdir listing_tmp ; fi
if [[ -d "osc_tmp" ]] ; then rm osc_tmp/* ; fi
if [[ ! -d "osc_tmp" ]] ; then mkdir osc_tmp ; fi

echo Getting file list from http://planet.openstreetmap.org/replication/day...
for (( num=0; num<=999; num++ )) ; do
{
	n="$(printf "%03d" $num)"
	lynx --dump --nolist http://planet.openstreetmap.org/replication/day/000/$n/ | grep txt | sed 's/\[TXT\]//g'| sed 's/^[ \t]*//' > listing_tmp/$n.dmp
	if [[ $(stat --printf="%s" listing_tmp/$n.dmp) -lt 100 ]] ; then
		rm listing_tmp/$n.dmp
		break
	fi
}
done

# Calculate OSC filename which corresponds with currect planet
for file in listing_tmp/*.dmp ; do
	PLANET_TIMESTAMP_STRING=$(grep "$PLANET_TIMESTAMP" $file -R)
	PLANET_RDIR=$(basename $file)
	PLANET_RDIR=${PLANET_RDIR%.dmp}
	PLANET_TIMESTAMP_FILENAME=${PLANET_TIMESTAMP_STRING:0:3}
	if [[ -n $PLANET_TIMESTAMP_STRING ]] ; then break ; fi
done
# Calculate OSC filename which corresponds with first day of current month
for file in listing_tmp/*.dmp ; do
	FIRST_DAY_TIMESTAMP_STRING=$(grep "$FIRST_DAY_TIMESTAMP" $file -R)
	FIRST_DAY_RDIR=$(basename $file)
	FIRST_DAY_RDIR=${FIRST_DAY_RDIR%.dmp}
	file=$(basename $file)
	FIRST_DAY_TIMESTAMP_FILENAME=${FIRST_DAY_TIMESTAMP_STRING:0:3}
	if [[ -n $FIRST_DAY_TIMESTAMP_STRING ]] ; then break ; fi
done

echo Downloading OSC from $PLANET_RDIR/$PLANET_TIMESTAMP_FILENAME to $FIRST_DAY_RDIR/$FIRST_DAY_TIMESTAMP_FILENAME
for (( osc=$(echo $PLANET_RDIR$PLANET_TIMESTAMP_FILENAME | sed 's/^0*//g'); osc<=$(echo $FIRST_DAY_RDIR$FIRST_DAY_TIMESTAMP_FILENAME | sed 's/^0*//g'); osc++ )) ; do
	osc_seq="$(printf "%06d" $osc)"
	wget --directory-prefix=osc_tmp/ -nc -c http://planet.openstreetmap.org/replication/day/000/${osc_seq:0:3}/${osc_seq:3:6}.osc.gz
done
echo Unpacking...
gunzip -f osc_tmp/*.gz
echo Applying OSC...
time osmconvert $PLANET_FULL_PATH $(find osc_tmp/ -name *.osc) --out-o5m > "$PLANET_DIR/$PLANET_FILENAME.o5mtmp"
if [[ $? != 0 ]] ; then
	echo Error applying OSC... ($?)
else
	mv -f "$PLANET_DIR/$PLANET_FILENAME.o5mtmp" "$PLANET_DIR/$PLANET_FILENAME.o5m"
	NEW_PLANET_TIMESTAMP=$(osmconvert $PLANET_DIR/$PLANET_FILENAME.o5m --out-statistics | grep "timestamp max" | sed 's/timestamp max: //g')
	touch -d "$NEW_PLANET_TIMESTAMP" $PLANET_DIR/$PLANET_FILENAME.o5m
	echo Planet ${PLANET_DIR}/${PLANET_FILENAME}.o5m updated to $NEW_PLANET_TIMESTAMP
	rm osc_tmp/*
	rm listing_tmp/*
fi
