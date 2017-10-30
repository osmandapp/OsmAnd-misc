#!/bin/bash
# Start overpass manually (without jenkins)

cd /home/overpass
EXEC_DIR="/home/overpass/osm3s"
LOG_DIR="/home/overpass"
killall osm3s_query 2> err.txt
killall dispatcher 2> err.txt
kill $(ps aux | grep 'apply_osc_to_db' | awk '{print $2}')
kill $(ps aux | grep 'bin/fetch_osc.sh' | awk '{print $2}')
kill $(ps aux | grep 'update_from_dir --osc-dir' | awk '{print $2}')
rm -f $EXEC_DIR/../db/osm3s_v0.7.52_osm_base 2> /dev/null
if [[ -f "/dev/shm/osm3s_v0.7.52_osm_base" ]] ; then
  rm -f /dev/shm/osm3s_v0.7.52_osm_base
fi
if [[ -f "$EXEC_DIR/../db/osm3s_v0.7.52_osm_base" ]] ; then
  rm -f $EXEC_DIR/../db/osm3s_v0.7.52_osm_base
fi
$EXEC_DIR/bin/dispatcher --terminate > err.txt
echo "Starting main dispatcher"
nohup $EXEC_DIR/bin/dispatcher --osm-base --attic --db-dir=$EXEC_DIR/../db &
kill $(ps aux | grep 'bin/fetch_osc.sh' | awk '{print $2}') || true 2> err.txt
nohup $EXEC_DIR/bin/fetch_osc.sh $(cat $EXEC_DIR/../db/replicate_id) http://planet.openstreetmap.org/replication/minute/ $EXEC_DIR/../osc &> $LOG_DIR/fetch_osc.log &

rm -f $EXEC_DIR/../db/osm_base_shadow.lock
echo "Starting apply_osc_to_db.sh"
echo $(cat $EXEC_DIR/../db/replicate_id)
nohup $EXEC_DIR/bin/apply_osc_to_db.sh $EXEC_DIR/../osc $(cat $EXEC_DIR/../db/replicate_id) --meta=attic &> $LOG_DIR/apply_osc.log &
