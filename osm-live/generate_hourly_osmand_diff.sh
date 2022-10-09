#!/bin/bash -xe
RESULT_DIR="/home/osmlive/"
OSMAND_MAP_CREATOR_PATH=OsmAndMapCreator

# For local test
# How to generate files locally:
# 1. Create .proc_timestamp in RESULT_DIR with date/time: "2020-12-30 10:10"
# 2. Execute this script
# 3. Stop when diff is done
#RESULT_DIR=/home/xmd5a/tmp/live_germany2
#OSMAND_MAP_CREATOR_PATH=/home/xmd5a/utilites/OsmAndMapCreator-main
#REMOTE_SSH_STRING="ssh jenkins@builder.osmand.net"

export JAVA_OPTS="-Xms512M -Xmx24014M"
chmod +x $OSMAND_MAP_CREATOR_PATH/utilities.sh

SRTM_DIR="/home/relief-data/srtm/"
# CURRENT_SEC=$(date -u "+%s")
START="$(cat $RESULT_DIR/.proc_timestamp)"
echo "Begin with timestamp: $START"
START_ARRAY=($START)
START_DAY=${START_ARRAY[0]}
START_TIME=${START_ARRAY[1]}
DATE_LOG_FILE=date.log

PERIOD_1_SEC=300;
PERIOD_2_SEC=600;
PERIOD_3_SEC=1200;
PERIOD_4_SEC=1800;
PERIOD_5_SEC=2400;

LOG_SIZE=$(wc -l <"$DATE_LOG_FILE") || true
if [ $LOG_SIZE -ge 1000  ]; then
  echo "START" > $DATE_LOG_FILE
fi

while true; do
  START_DATE="${START_DAY}T${START_TIME}:00Z"
  START_SEC=$(date -u --date="$START_DATE" "+%s")
  # database timestamp
  DB_SEC=$(date -u --date="$($REMOTE_SSH_STRING /home/overpass/osm3s/cgi-bin/timestamp | tail -1)" "+%s")

  if [ -z "$PERIOD" ]; then
    PERIOD_SEC=$PERIOD_1_SEC;
    if (( $DB_SEC > $START_SEC + $PERIOD_5_SEC + 60 )); then
      PERIOD_SEC=$PERIOD_5_SEC;
    elif (( $DB_SEC > $START_SEC + $PERIOD_4_SEC + 60 )); then
      PERIOD_SEC=$PERIOD_4_SEC;
    elif (( $DB_SEC > $START_SEC + $PERIOD_3_SEC + 60 )); then
      PERIOD_SEC=$PERIOD_3_SEC;
    elif (( $DB_SEC > $START_SEC + $PERIOD_2_SEC + 60 )); then
      PERIOD_SEC=$PERIOD_2_SEC;
    fi
  else 
    PERIOD_SEC=$PERIOD
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
  
  
  QUERY_LOW_EMMISIONS_ZONE="[timeout:3600][maxsize:160000000];
    relation[\"boundary\"=\"low_emission_zone\"];
    (._;>;);
    out meta;"
  LOW_EMMISION_ZONE_FILE=low_emission_zone.osm.gz
  ## UPDATE LOW_EMMISION_ZONE_FILE once per day 
  if ! test "`find $LOW_EMMISION_ZONE_FILE -mmin -1440`"; then 
    echo "$QUERY_LOW_EMMISIONS_ZONE" | $REMOTE_SSH_STRING /home/overpass/osm3s/bin/osm3s_query  | gzip > $LOW_EMMISION_ZONE_FILE
  fi
  #if [ -f "$FINAL_FOLDER/src/${FILENAME_DIFF}_before.obf.gz" ]; then
  # disable for now
  if false; then
    # this path to speedup generation 10 times (if obf were generated before)
      
    $OSMAND_MAP_CREATOR_PATH/utilities.sh generate-obf-diff \
    "$FINAL_FOLDER/src/${FILENAME_DIFF}_before.obf.gz" \
    "$FINAL_FOLDER/src/${FILENAME_DIFF}_after.obf.gz" \
    $FILENAME_DIFF.diff.obf \
    "$FINAL_FOLDER/src/${FILENAME_DIFF}_diff.osm.gz"
    
    gzip -c $FILENAME_DIFF.diff.obf > $FINAL_FILE
    TZ=UTC touch -c -d "$END_DATE" $FINAL_FILE
  
    $OSMAND_MAP_CREATOR_PATH/utilities.sh split-obf \
    $FILENAME_DIFF.diff.obf $RESULT_DIR  \
     "$DATE_NAME" "_$TIME_NAME"
  
  
    rm -r *.osm || true
    rm -r *.rtree* || true
    rm -r *.obf || true
  else
    echo "$START_DATE - $END_DATE query data: $(date -u)" >> $DATE_LOG_FILE
    FULL_QUERY="
    // 1. get all nodes, ways, relation changed between START - END
    (
      node(changed:\"$START_DATE\",\"$END_DATE\");
      way(changed:\"$START_DATE\",\"$END_DATE\");
      relation(changed:\"$START_DATE\",\"$END_DATE\");
    )->.a;
    // 2.1 retrieve all nodes/ways for changed relation, 
    // so later we could retrieve all relations for Ways (not only changed)  and make ways complete
    // (way(r.a);.a;) ->.a; 
    // (node(r.a);.a;) ->.a; 
    // 2.2 retrieve all ways for changed nodes to change ways geometry
    (way(bn.a);.a;) ->.a; // get all ways by nodes
    // 2.3 retrieve all relations for changed nodes / ways, so we can propagate right tags to them
    (relation(bn.a);.a;) ->.a;
    (relation(bw.a);.a;) ->.a;
    // 3. final step make all relations / way / node complete
    (way(r.a);.a;) ->.a; 
    (node(r.a);.a;) ->.a;
    (node(w.a);.a;) ->.a;
    .a out meta;
    "
    QUERY_START="[timeout:3600][maxsize:2000000000][date:\"$START_DATE\"]; $FULL_QUERY";
    QUERY_END="[timeout:3600][maxsize:2000000000][date:\"$END_DATE\"]; $FULL_QUERY";
    QUERY_DIFF="[timeout:3600][maxsize:2000000000][diff:\"$START_DATE\",\"$END_DATE\"];
    (
      node(changed:\"$START_DATE\",\"$END_DATE\");
      way(changed:\"$START_DATE\",\"$END_DATE\");
      relation(changed:\"$START_DATE\",\"$END_DATE\");
    )->.a;

    .a out geom meta;
    "
    echo # 1. Query rich diffs
    echo -e "$QUERY_START" | $REMOTE_SSH_STRING /home/overpass/osm3s/bin/osm3s_query > $FILENAME_START.osm &
    echo -e "$QUERY_END" | $REMOTE_SSH_STRING /home/overpass/osm3s/bin/osm3s_query  > $FILENAME_END.osm &
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
    echo "$START_DATE - $END_DATE generate obf: $(date -u)" >> $DATE_LOG_FILE
    echo # 2. Generate obf files & query change file
    echo "$QUERY_DIFF" | $REMOTE_SSH_STRING /home/overpass/osm3s/bin/osm3s_query  > $FILENAME_CHANGE.osm  &
    # SRTM takes too much time and memory at this step (probably it could be used at the change step)
    $OSMAND_MAP_CREATOR_PATH/utilities.sh generate-obf-no-address $FILENAME_START.osm --add-region-tags --extra-relations="$LOW_EMMISION_ZONE_FILE" & # --srtm="$SRTM_DIR" &
    $OSMAND_MAP_CREATOR_PATH/utilities.sh generate-obf-no-address $FILENAME_END.osm --add-region-tags --extra-relations="$LOW_EMMISION_ZONE_FILE" & # --srtm="$SRTM_DIR" &
    wait

    TZ=UTC touch -c -d "$END_DATE" $FILENAME_CHANGE.osm
    if ! grep -q "<\/osm>"  $FILENAME_CHANGE.osm; then
       exit 1;
    fi
    date -u
    echo "$START_DATE - $END_DATE zip files: $(date -u)" >> $DATE_LOG_FILE
    echo # 3. ZIP all files
    gzip -c $FILENAME_START.obf > $FINAL_FOLDER/src/${FILENAME_DIFF}_before.obf.gz &
    gzip -c $FILENAME_END.obf > $FINAL_FOLDER/src/${FILENAME_DIFF}_after.obf.gz &
    gzip -c $FILENAME_CHANGE.osm > $FINAL_FOLDER/src/${FILENAME_DIFF}_diff.osm.gz &
    wait
    #gzip -c $FILENAME_START.osm > $FINAL_FOLDER/src/${FILENAME_DIFF}_before.osm.gz
    #gzip -c $FILENAME_END.osm > $FINAL_FOLDER/src/${FILENAME_DIFF}_after.osm.gz
  
    echo "$START_DATE - $END_DATE generate diff: $(date -u)" >> $DATE_LOG_FILE
    echo # 4. Generate diff files, split files and cleaning
    $OSMAND_MAP_CREATOR_PATH/utilities.sh generate-obf-diff \
    $FILENAME_START.obf $FILENAME_END.obf $FILENAME_DIFF.diff.obf $FILENAME_CHANGE.osm

    gzip -c $FILENAME_DIFF.diff.obf > $FINAL_FILE
    TZ=UTC touch -c -d "$END_DATE" $FINAL_FILE
  
    $OSMAND_MAP_CREATOR_PATH/utilities.sh split-obf \
    $FILENAME_DIFF.diff.obf $RESULT_DIR  \
     "$DATE_NAME" "_$TIME_NAME"
  
  
    rm -r *.osm || true
    rm -r *.rtree* || true
    rm -r *.obf || true
    echo "$START_DATE - $END_DATE done: $(date -u)" >> $DATE_LOG_FILE
  fi 

  START_DAY=$NSTART_DAY
  START_TIME=$NSTART_TIME

  echo "$NSTART_DAY $NSTART_TIME" > "${RESULT_DIR}.proc_timestamp"
done
