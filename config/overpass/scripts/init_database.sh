#!/bin/sh
nohup osm3s/bin/download_clone.sh --source=http://dev.overpass-api.de/api_drolbr/ --db-dir="db/" --meta=attic &> clone.log&
