wget -O osm-data/countries_admin_level_2.osm --post-file=osm-data/queries/countries_admin_level_2.txt "http://overpass-api.de/api/interpreter"

sed -i "s/<\/osm>//g" osm-data/countries_admin_level_2.osm
cat osm-data/queries/countries_admin_level_2-addition.txt >> osm-data/countries_admin_level_2.osm
echo "</osm>" >> osm-data/countries_admin_level_2.osm
sed -i "s/en\" v=\"Saint Helena,/en\" v=\"Saint Helena/g" osm-data/countries_admin_level_2.osm #this is needed because I don't know how to fix generate-osm-poly.py. It crashes at this country
