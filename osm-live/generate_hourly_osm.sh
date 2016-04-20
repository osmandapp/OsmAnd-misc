#!/bin/bash -x
# INITIAL
#rm -rf /home/osm-planet/aosmc/*
#echo "2016-04-01 00:00" > /home/osm-planet/aosmc/.proc_timestamp
#echo "2016-04-02 00:00" > /home/osm-planet/aosmc/.current_timestamp
### BEGIN
END=( $(cat /home/osm-planet/aosmc/.current_timestamp) )
START=( $(cat /home/osm-planet/aosmc/.proc_timestamp) )
END_DAY=${END[0]}
END_TIME=${END[1]}
START_DAY=${START[0]}
START_TIME=${START[1]}
while [ ! "$END_DAY $END_TIME" ==  "$START_DAY $START_TIME" ]; do

START_DATE="${START_DAY}T${START_TIME}:00Z"
FILENAME="$(echo $START_DAY | tr '-' _)-$(echo $START_TIME| tr ':' _)"
NEXT="$START_DAY $START_TIME 30 minutes"
NSTART_TIME=$(date +'%H' -d "$NEXT"):$(date +'%M' -d "$NEXT")
NSTART_DAY=$(date +'%Y' -d "$NEXT")-$(date +'%m' -d "$NEXT")-$(date +'%d' -d "$NEXT")
END_DATE="${NSTART_DAY}T${NSTART_TIME}:00Z"
echo "Query between $START_DATE and $END_DATE"
QUERY="
[timeout:1800]
[adiff:\"$START_DATE\",\"$END_DATE\"];
(
	node(changed:\"$START_DATE\",\"$END_DATE\");
	way(changed:\"$START_DATE\",\"$END_DATE\");
	relation(changed:\"$START_DATE\",\"$END_DATE\");
)->.changed;
.changed out geom meta;
"

echo $QUERY | /home/overpass/osm3s/bin/osm3s_query | gzip -vc > /home/osm-planet/aosmc/$FILENAME.osm.gz 

java -XX:+UseParallelGC -Xmx2096M -Xmn256M \
-Djava.util.logging.config.file=tools/obf-generation/batch-logging.properties \
-cp "OsmAndMapCreator/OsmAndMapCreator.jar:OsmAndMapCreator/lib/OsmAnd-core.jar:OsmAndMapCreator/lib/*.jar" \
net.osmand.data.diff.AugmentedDiffsInspector \
/home/osm-planet/aosmc/$FILENAME.osm.gz /home/osm-planet/aosmc OsmAndMapCreator/regions.ocbf
START_DAY=$NSTART_DAY
START_TIME=$NSTART_TIME
done
echo "$END_DAY $END_DAY" > /home/osm-planet/aosmc/.proc_timestamp
