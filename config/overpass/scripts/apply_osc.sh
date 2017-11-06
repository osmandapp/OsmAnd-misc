#!/bin/bash
rm -f db/osm_base_shadow.lock
#./osm3s/bin/apply_osc_to_db.sh osc 1845940 --meta=attic
nohup ./osm3s/bin/apply_osc_to_db.sh osc $(cat db/replicate_id) --meta=attic &> apply_osc.log&
