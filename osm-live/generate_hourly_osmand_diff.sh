#!/bin/bash -xe
RESULT_DIR="/home/osmlive/"

export JAVA_OPTS="-Xms512M -Xmx8014M"
chmod +x OsmAndMapCreator/utilities.sh

SRTM_DIR="/home/relief-data/srtm/"
# CURRENT_SEC=$(date -u "+%s")
START="$(cat $RESULT_DIR/.proc_timestamp)"
echo "Begin with timestamp: $START"
START_ARRAY=($START)
START_DAY=${START_ARRAY[0]}
START_TIME=${START_ARRAY[1]}

PERIOD_1_SEC=600;
PERIOD_2_SEC=1200;
PERIOD_3_SEC=1800;

while true; do
  START_DATE="${START_DAY}T${START_TIME}:00Z"
  START_SEC=$(date -u --date="$START_DATE" "+%s")
  # database timestamp
  DB_SEC=$(date -u --date="$(/home/overpass/osm3s/cgi-bin/timestamp | tail -1)" "+%s")

  PERIOD_SEC=$PERIOD_1_SEC;
  if (( $DB_SEC > $START_SEC + $PERIOD_3_SEC )); then
    PERIOD_SEC=$PERIOD_3_SEC;
  elif (( $DB_SEC > $START_SEC + $PERIOD_2_SEC )); then
    PERIOD_SEC=$PERIOD_2_SEC;
  fi

  NEXT="$START_DAY $START_TIME $PERIOD_SEC seconds"

  NSTART_TIME=$(date +'%H' -d "$NEXT"):$(date +'%M' -d "$NEXT")
  NSTART_DAY=$(date +'%Y' -d "$NEXT")-$(date +'%m' -d "$NEXT")-$(date +'%d' -d "$NEXT")
  if [ ! "$NSTART_DAY" = "$START_DAY" ]; then
    NSTART_TIME="00:00"
  fi
  END_DATE="${NSTART_DAY}T${NSTART_TIME}:00Z"
  END_SEC=$(date -u --date="$END_DATE" "+%s")
  # give 60 seconds delay to wait for overpass to finish internal ops
  if (( $END_SEC > $DB_SEC - 60 )); then
    echo "END date $END_DATE is in the future of database!!!"
    exit 0;
  fi;
  
  DATE_NAME="$(echo ${NSTART_DAY:2} | tr '-' _ | tr ':' _ )"
  TIME_NAME="$(echo ${NSTART_TIME} | tr '-' _ | tr ':' _ )"
  if [ "$TIME_NAME" = "00_00" ]; then
    DATE_NAME="$(echo ${START_DAY:2} | tr '-' _ | tr ':' _ )"
    TIME_NAME="24_00"
  fi
  FILENAME_START=Diff-start
  FILENAME_END=Diff-end
  FILENAME_CHANGE=change
  FILENAME_DIFF="${DATE_NAME}_${TIME_NAME}"
  FINAL_FOLDER=$RESULT_DIR/_diff/$DATE_NAME/
  FINAL_FILE=$FINAL_FOLDER/$FILENAME_DIFF.obf.gz
  mkdir -p $FINAL_FOLDER/src/
  
  
  

  #if [ -f "$FINAL_FOLDER/src/${FILENAME_DIFF}_before.obf.gz" ]; then
  # disable for now
  if false; then
    # this path to speedup generation 10 times (if obf were generated before)
      
    OsmAndMapCreator/utilities.sh generate-obf-diff \
    "$FINAL_FOLDER/src/${FILENAME_DIFF}_before.obf.gz" \
    "$FINAL_FOLDER/src/${FILENAME_DIFF}_after.obf.gz" \
    $FILENAME_DIFF.diff.obf \
    "$FINAL_FOLDER/src/${FILENAME_DIFF}_diff.osm.gz"
    
    gzip -c $FILENAME_DIFF.diff.obf > $FINAL_FILE
    TZ=UTC touch -c -d "$END_DATE" $FINAL_FILE
  
    OsmAndMapCreator/utilities.sh split-obf \
    $FILENAME_DIFF.diff.obf $RESULT_DIR  \
     "$DATE_NAME" "_$TIME_NAME"
  
  
    rm -r *.osm || true
    rm -r *.rtree* || true
    rm -r *.obf || true
  else
    echo "Query between $START_DATE and $END_DATE"
    date -u
    QUERY_START="[timeout:3600][maxsize:2000000000][date:\"$START_DATE\"];
    
(
  node(changed:\"$START_DATE\",\"$END_DATE\");
  way(changed:\"$START_DATE\",\"$END_DATE\");
  relation(changed:\"$START_DATE\",\"$END_DATE\");
)->.a;
(way(bn.a);.a;) ->.a;
(relation(bn.a);.a;) ->.a;
(relation(bw.a);.a;) ->.a;
(way(r.a);.a;) ->.a;
(node(w.a);.a;) ->.a;

.a out geom meta;
"
    QUERY_END="[timeout:3600][maxsize:2000000000][date:\"$END_DATE\"];
    
(
  node(changed:\"$START_DATE\",\"$END_DATE\");
  way(changed:\"$START_DATE\",\"$END_DATE\");
  relation(changed:\"$START_DATE\",\"$END_DATE\");
)->.a;
(way(bn.a);.a;) ->.a;
(relation(bn.a);.a;) ->.a;
(relation(bw.a);.a;) ->.a;
(way(r.a);.a;) ->.a;
(node(w.a);.a;) ->.a;

.a out geom meta;
"
    QUERY_DIFF="[timeout:3600][maxsize:2000000000][diff:\"$START_DATE\",\"$END_DATE\"];
    
(
   node(changed:\"$START_DATE\",\"$END_DATE\");
   way(changed:\"$START_DATE\",\"$END_DATE\");
   relation(changed:\"$START_DATE\",\"$END_DATE\");
)->.a;

.a out geom meta;
"
    echo # 1. Query rich diffs
    echo -e "$QUERY_START" | /home/overpass/osm3s/bin/osm3s_query > $FILENAME_START.osm &
    echo -e "$QUERY_END" | /home/overpass/osm3s/bin/osm3s_query  > $FILENAME_END.osm &
    wait

    if ! grep -q "<\/osm>"  $FILENAME_START.osm; then
        rm $FILENAME_START.osm;
        exit 1;
    fi
    
    if ! grep -q "<\/osm>"  $FILENAME_END.osm; then
        rm $FILENAME_END.osm;
        exit 1;
    fi
    TZ=UTC touch -c -d "$END_DATE" $FILENAME_START.osm
    TZ=UTC touch -c -d "$END_DATE" $FILENAME_END.osm
    date -u

    echo # 2. Generate obf files & query change file
    echo "$QUERY_DIFF" | /home/overpass/osm3s/bin/osm3s_query  > $FILENAME_CHANGE.osm  &
    # SRTM takes too much time and memory at this step (probably it could be used at the change step)
    OsmAndMapCreator/utilities.sh generate-obf-no-address $FILENAME_START.osm & # --srtm="$SRTM_DIR" &
    OsmAndMapCreator/utilities.sh generate-obf-no-address $FILENAME_END.osm & # --srtm="$SRTM_DIR" &
    wait

    TZ=UTC touch -c -d "$END_DATE" $FILENAME_CHANGE.osm
    if ! grep -q "<\/osm>"  $FILENAME_CHANGE.osm; then
       exit 1;
    fi
    date -u
    
    echo # 3. ZIP all files
    gzip -c $FILENAME_START.obf > $FINAL_FOLDER/src/${FILENAME_DIFF}_before.obf.gz &
    gzip -c $FILENAME_END.obf > $FINAL_FOLDER/src/${FILENAME_DIFF}_after.obf.gz &
    gzip -c $FILENAME_CHANGE.osm > $FINAL_FOLDER/src/${FILENAME_DIFF}_diff.osm.gz &
    wait
    #gzip -c $FILENAME_START.osm > $FINAL_FOLDER/src/${FILENAME_DIFF}_before.osm.gz
    #gzip -c $FILENAME_END.osm > $FINAL_FOLDER/src/${FILENAME_DIFF}_after.osm.gz
  
  
    echo # 4. Generate diff files, split files and cleaning
    OsmAndMapCreator/utilities.sh generate-obf-diff \
    $FILENAME_START.obf $FILENAME_END.obf $FILENAME_DIFF.diff.obf $FILENAME_CHANGE.osm

    gzip -c $FILENAME_DIFF.diff.obf > $FINAL_FILE
    TZ=UTC touch -c -d "$END_DATE" $FINAL_FILE
  
    OsmAndMapCreator/utilities.sh split-obf \
    $FILENAME_DIFF.diff.obf $RESULT_DIR  \
     "$DATE_NAME" "_$TIME_NAME"
  
  
    rm -r *.osm || true
    rm -r *.rtree* || true
    rm -r *.obf || true
  fi 

  START_DAY=$NSTART_DAY
  START_TIME=$NSTART_TIME

  echo "$NSTART_DAY $NSTART_TIME" > "${RESULT_DIR}.proc_timestamp"
done
