#!/bin/bash
# Note that Overpass normally should be started from Jenkins - OsmLive_FetchAndUpdateOverpass. Only dispatcher should work before launching this job.

killall dispatcher || true
rm -f db/osm3s_v0.7.52_osm_base
if [[ -f "/dev/shm/osm3s_v0.7.52_osm_base" ]] ; then
  rm -f /dev/shm/osm3s_v0.7.52_osm_base
fi
#./osm3s/bin/dispatcher --terminate
nohup ./osm3s/bin/dispatcher --osm-base --attic --db-dir=db &> dispatcher.log &