#!/bin/bash
cat files | while read nm id nm2 fnm
do
	echo "Process $nm $id into $fnm"
	wget -O - "http://osm102.openstreetmap.fr/~jocelyn/polygons/index.py?id=$id" > index.html
	wget -O - --post-data 'generate=Submit&x=0.050000&y=0.010000&z=0.035000' "http://osm102.openstreetmap.fr/~jocelyn/polygons/index.py?id=$id" > index.html
	wget -O - "http://osm102.openstreetmap.fr/~jocelyn/polygons/get_poly.py?id=$id&params=0.050000-0.010000-0.035000" > ../polygons/russia-regions/$fnm.poly	
done
