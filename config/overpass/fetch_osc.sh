#!/bin/bash
#kill $(ps aux | grep 'bin/fetch_osc.sh' | awk '{print $2}') || true
echo start
nohup ./osm3s/bin/fetch_osc.sh $(cat db/replicate_id) http://planet.openstreetmap.org/replication/minute/ osc &> fetch_osc.log&
