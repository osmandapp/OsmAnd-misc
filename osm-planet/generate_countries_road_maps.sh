#!/bin/bash
#countries=(ukraine india  italy  germany france netherlands canada)
#suffixes=( europe  asia   europe europe  europe europe      northamerica)
countries=(germany)
suffixes=(europe)

base_dir=$(pwd)
road_dir="$base_dir/.work/road"
osm_dir="$base_dir/.work/osm/"
addresses_dir="$base_dir/.work/addresses/"
indexes_dir="$base_dir/.work/indexes/"
road_source_dir="/mnt/home-hdd/www/road-indexes"
address_source_dir="/home/osm-planet/osm-extract"
road_obfs=()
i=0
s=0
inspector_parameters=

mkdir -p $osm_dir
mkdir -p $road_dir
mkdir -p $indexes_dir
mkdir -p $addresses_dir

echo '<?xml version="1.0" encoding="utf-8"?>
<batch_process>
	<process_attributes mapZooms="" renderingTypesFile="" zoomWaySmoothness="2" osmDbDialect="sqlite_in_memory" mapDbDialect="sqlite_in_memory"/>
	<process directory_for_osm_files="'$osm_dir'" directory_for_index_files="'$addresses_dir'" directory_for_generation="'$addresses_dir'" indexPOI="false" indexMap="false" indexRouting="false" indexTransport="false" indexAddress="true"></process>
</batch_process>' > $base_dir/tools/obf-generation/indexes-addresses-batch-generate-inmem.xml

for country in "${countries[@]}"
do
	if [[ -f "$address_source_dir/$country.o5m" ]] ; then
		echo "Getting ${country^} map source"
 		osmconvert "$address_source_dir/$country.o5m" --out-pbf > "$osm_dir/$country.osmtmp.pbf"
	elif [[ -f "$address_source_dir/${country}_${suffixes[$s]}/${country}_${suffixes[$s]}.pbf" ]] ; then
		echo "Getting ${country^} map source"
 		cp "$address_source_dir/${country}_${suffixes[$s]}/${country}_${suffixes[$s]}.pbf" "$osm_dir/$country.osmtmp.pbf"
	else
		echo "Local ${country^} map source not found"
	fi
#	echo "Converting to osm..."
#	osmconvert "$osm_dir/$country.osmtmp.pbf" --out-osm >"$osm_dir/$country.osm"
#	echo "Filtering..."
#	osmfilter "$osm_dir/$country.osm" --keep-tags="all addr:*= place= highway=" | osmconvert - --out-pbf>"$osm_dir/$country.osm.pbf"
	rm -f "$osm_dir/$country.osmtmp.pbf"
	rm -f "$osm_dir/$country.osm"
	s=$((s + 1))
done

echo "Now starting OsmAndMapCreator to create address maps"
java -XX:+UseParallelGC -Xmx16096M -Xmn512M \
-Djava.util.logging.config.file=tools/obf-generation/batch-logging.properties \
-cp "tools/OsmAndMapCreator/OsmAndMapCreator.jar:tools/OsmAndMapCreator/lib/*.jar" \
net.osmand.data.index.IndexBatchCreator tools/obf-generation/indexes-addresses-batch-generate-inmem.xml

cd tools/OsmAndMapCreator/

for country in "${countries[@]}"
do
	echo -e "\n --- Processing $country ${suffixes[$i]}"
	unzip -u "$road_source_dir/${country^}_*_2.road.obf.zip" -d "$road_dir" -x "${country^}_${suffixes[$i]}_2.road.obf"
	road_obfs=$(find $road_dir -name "${country^}_*.road.obf")
	if [[ -z $(find $road_dir -name "${country^}_*.road.obf") ]] ; then
		echo "!!! No required files found in $road_dir"
		i=$((i + 1))
		continue
	else echo Found road only obfs: $road_obfs
	fi
	shopt -s nullglob
	for file in "$road_dir/${country^}_*.road.obf"
	do
		inspector_parameters=$(echo ${file} | sed "s/.road.obf/.road.obf -3/g")
	done
	echo "Merging road maps with address map"
	echo $inspector_parameters | sed "s@$road_dir/@@g"
	./inspector.sh -c "$indexes_dir/${country^}_${suffixes[$i]}.road.obf" $inspector_parameters $addresses_dir/${country^}_2.obf
	i=$((i + 1))
	inspector_parameters=
done
rm -rf $road_dir