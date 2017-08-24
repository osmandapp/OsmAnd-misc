#!/bin/bash -xe
START=($1)
END=($2)
echo "Current timestamp $END"
echo "Processed timestamp $START"
END_DAY=${END[0]}
END_TIME=${END[1]}
START_DAY=${START[0]}
START_TIME=${START[1]}

DB_SEC=$(date -u --date="$(curl http://builder.osmand.net:8081/api/timestamp)" "+%s")
END_SEC=$(date -u --date="$END_DAY $END_TIME" "+%s")
if [ $END_SEC \> $DB_SEC ]; then      
	echo "END date is in the future of database!!!"
	exit 1;
fi;

while [ ! "$END_DAY $END_TIME" ==  "$START_DAY $START_TIME" ]; do
RESULT_DIR="/home/osm-planet/osmlive_test"
START_DATE="${START_DAY}T${START_TIME}:00Z"
FILENAME_START="$(echo $START_DATE | tr '-' _)"
NEXT="$START_DAY $START_TIME 30 minutes"
NSTART_TIME=$(date +'%H' -d "$NEXT"):$(date +'%M' -d "$NEXT")
NSTART_DAY=$(date +'%Y' -d "$NEXT")-$(date +'%m' -d "$NEXT")-$(date +'%d' -d "$NEXT")
END_DATE="${NSTART_DAY}T${NSTART_TIME}:00Z"
FILELENAME_END="$(echo $END_DATE | tr '-' _)"
echo "Query between $START_DATE and $END_DATE"
QUERY_START="
[timeout:1800][maxsize:2000000000]
[date:\"$START_DATE\"];
(
  node(changed:\"$START_DATE\",\"$END_DATE\");
  way(changed:\"$START_DATE\",\"$END_DATE\");
  relation(changed:\"$START_DATE\",\"$END_DATE\");
)->.a;
(way(bn.a);.a) ->.a;
(relation(bn.a);.a) ->.a;
(relation(bw.a);.a) ->.a;
(way(r.a);.a) ->.a;
(node(w.a);.a) ->.a;
	.a out geom meta;
"
QUERY_END="
[timeout:1800][maxsize:2000000000]
[date:\"$END_DATE\"];
(
  node(changed:\"$START_DATE\",\"$END_DATE\");
  way(changed:\"$START_DATE\",\"$END_DATE\");
  relation(changed:\"$START_DATE\",\"$END_DATE\");
)->.a;
(way(bn.a);.a) ->.a;
(relation(bn.a);.a) ->.a;
(relation(bw.a);.a) ->.a;
(way(r.a);.a) ->.a;
(node(w.a);.a) ->.a;
	.a out geom meta;
"

echo $QUERY_START | /home/overpass/osm3s/bin/osm3s_query | gzip -vc > $FILENAME_START.osm.gz 
TZ=UTC touch -c -d "$START_DATE" $FILENAME_START.osm.gz

echo $QUERY_END | /home/overpass/osm3s/bin/osm3s_query | gzip -vc > $FILENAME_END.osm.gz 
TZ=UTC touch -c -d "$END_DATE" $FILENAME_END.osm.gz 

gunzip -c $FILENAME_START.osm.gz | grep "<\/osm>" > /dev/null
gunzip -c $FILENAME_END.osm.gz | grep "<\/osm>" > /dev/null
if [ $? = 1 ]; then
	echo "Overpass query /home/osm-planet/aosmc/$FILENAME_START.osm.gz failed!"
	echo "Overpass query /home/osm-planet/aosmc/$FILENAME_END.osm.gz failed!"		
	exit 1;
fi
OsmAndMapCreator/utilities.sh generate_map $BUFFER_DIR/$FILENAME_START.osm
OsmAndMapCreator/utilities.sh generate_map $BUFFER_DIR/$FILENAME_END.osm

gunzip -c $BUFFER_DIR/$FILENAME_START.obf.gz
gunzip -c $BUFFER_DIR/$FILENAME_END.obf.gz

java -XX:+UseParallelGC -Xmx8096M -Xmn256M \
-Djava.util.logging.config.file=tools/obf-generation/batch-logging.properties \
-cp "OsmAndMapCreator/OsmAndMapCreator.jar:OsmAndMapCreator/lib/OsmAnd-core.jar:OsmAndMapCreator/lib/*.jar" \
net.osmand.data.diff.DailyDiffGenerator \
-gen $FILENAME_START.obf $FILENAME_END.obf $RESULT_DIR

rm -r *.osm.gz
rm -r *.obf

START_DAY=$NSTART_DAY
START_TIME=$NSTART_TIME
done

