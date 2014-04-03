#!/bin/bash
ID=_`(date +"%d_%m_%H_%M")`
/var/lib/postgresql/osmosis.run --rri workingDirectory=/var/lib/postgresql/osmosis-workdir --simplify-change --write-xml-change changes$ID.osc.gz
# /var/lib/postgresql/osmosis.run --rri workingDirectory=/var/lib/postgresql/osmosis-workdir --simc --wx - \
#| osm2pgsql --append --style /var/lib/postgresql/osm2pgsql/osm2pgsql/default.style --number-processes 4 -d gis --slim -k --expire-tiles 13-18 --expire-output /var/lib/postgresql/expired_tiles.list

osm2pgsql --append --style /var/lib/postgresql/osm2pgsql/osm2pgsql/default.style --number-processes 4 -d gis --slim  --expire-tiles 13-18 --expire-output /var/lib/postgresql/expired_tiles$ID.list changes$ID.osc.gz
ls -larh changes$ID.osc.gz
rm changes$ID.osc.gz

cat /var/lib/postgresql/expired_tiles$ID.list | /var/lib/postgresql/mod_tile/render_expired --min-zoom=13
rm expired_tiles$ID.list
