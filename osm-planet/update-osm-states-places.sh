wget -O osm-data/states_places.osm --post-file=osm-data/queries/states_places.txt "http://overpass-api.de/api/interpreter"

# delete!!  node id="2912811859"
#    tag k="name" v="Maryland"
# this state brokes translations for US state Maryland