#!/bin/bash -xe
RESULT_DIR="/home/osm-planet/osmlive_test"
START=($1)
END=($2)
echo "Current timestamp $END"
echo "Processed timestamp $START"
END_DAY=${END[0]}
END_TIME=${END[1]}
START_DAY=${START[0]}
START_TIME=${START[1]}

chmod +x OsmAndMapCreator/utilities.sh
while [ ! "$END_DAY $END_TIME" ==  "$START_DAY $START_TIME" ]; do


START_DATE="${START_DAY}T${START_TIME}:00Z"
NEXT="$START_DAY $START_TIME 30 minutes"

NSTART_TIME=$(date +'%H' -d "$NEXT"):$(date +'%M' -d "$NEXT")
NSTART_DAY=$(date +'%Y' -d "$NEXT")-$(date +'%m' -d "$NEXT")-$(date +'%d' -d "$NEXT")
END_DATE="${NSTART_DAY}T${NSTART_TIME}:00Z"

#FILENAME_START="$(echo $START_DATE | tr '-' _)"
#FILENAME_END="$(echo $END_DATE | tr '-' _)"
FILENAME_START=Diff-start
FILENAME_END=Diff-end
FILENAME_DIFF="$(echo $NSTART_DAY-${NSTART_TIME} | tr '-' _ | tr ':' _ )"
DATE_FOLDER_NAME="$(echo $NSTART_DAY | tr '-' _ | tr ':' _ )"
TIME_FILE_SUFFIX="$(echo $NSTART_TIME | tr '-' _ | tr ':' _ )"

FINAL_FOLDER=$RESULT_DIR/diff/$NSTART_DAY/
FINAL_FILE=$FINAL_FOLDER/$FILENAME_DIFF.obf.gz
mkdir -p $FINAL_FOLDER

DB_SEC=$(date -u --date="$(curl http://builder.osmand.net:8081/api/timestamp)" "+%s")
END_SEC=$(date -u --date="$END_DATE" "+%s")
if [ $END_SEC \> $DB_SEC ]; then      
  echo "END date is in the future of database!!!"
  exit 1;
fi;

if [ ! -f $FINAL_FILE ]; then

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

  echo $QUERY_START | /home/overpass/osm3s/bin/osm3s_query > $FILENAME_START.osm
  TZ=UTC touch -c -d "$START_DATE" $FILENAME_START.osm

  echo $QUERY_END | /home/overpass/osm3s/bin/osm3s_query  > $FILENAME_END.osm
  TZ=UTC touch -c -d "$END_DATE" $FILENAME_END.osm 

  if ! grep -q "<\/osm>"  $FILENAME_START.osm; then
     exit 1;
  fi

  if ! grep -q "<\/osm>"  $FILENAME_END.osm; then
     exit 1;
  fi
  OsmAndMapCreator/utilities.sh generate-map $FILENAME_START.osm
  OsmAndMapCreator/utilities.sh generate-map $FILENAME_END.osm

  OsmAndMapCreator/utilities.sh generate-obf-diff \
  $FILENAME_START.obf $FILENAME_END.obf $FILENAME_DIFF.diff.obf

  gzip -c $FILENAME_DIFF.diff.obf > $FINAL_FILE
  TZ=UTC touch -c -d "$END_DATE" $FINAL_FILE
  gzip -c $FILENAME_START.obf > $FINAL_FOLDER/${FILENAME_DIFF}_before.obf.gz
  gzip -c $FILENAME_END.obf > $FINAL_FOLDER/${FILENAME_DIFF}_after.obf.gz
  gzip -c $FILENAME_START.osm > $FINAL_FOLDER/${FILENAME_DIFF}_before.osm.gz
  gzip -c $FILENAME_END.osm > $FINAL_FOLDER/${FILENAME_DIFF}_after.osm.gz


  OsmAndMapCreator/utilities.sh split-obf \
   $FILENAME_DIFF.diff.obf $RESULT_DIR  \
   OsmAndMapCreator/regions.ocbf "$DATE_FOLDER_NAME" "_$TIME_FILE_SUFFIX"


  rm -r *.osm || true
  rm -r *.rtree* || true
  rm -r *.obf || true
fi 

START_DAY=$NSTART_DAY
START_TIME=$NSTART_TIME
done