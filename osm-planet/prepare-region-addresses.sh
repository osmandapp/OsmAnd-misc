# This little script is only useful if the project is run without generateindexes running first
COUNTRIES=$1
# "british-isles:europe:europe/british-isles-latest.osm.pbf \
#  france:europe:europe/france-latest.osm.pbf \ 
#  germnany:europe:europe/germany-latest.osm.pbf \
#  italy:europe:europe/italy-latest.osm.pbf \
#  canada:north-america:north-america/canada-latest.osm.pbf"
# "russia:azia:RU.osm.pbf"
# "azores:europe:europe/azores-latest.osm.pbf albania:europe:europe/albania-latest.osm.pbf"
URL_PREFIX=$2
#http://download.geofabrik.de/
#http://gis-lab.info/projects/osm_dump/dump/latest/

WORKDIR=work
TARGETDIR=osm
rm -rf ${WORKDIR} 
mkdir -p ${WORKDIR} 
cd ${WORKDIR}


# test with 2 small countries


for country in ${COUNTRIES}; do
    basecountry=${country%%:*}
    L1=${country#*:}
    urlpart=${L1#*:}
    basecountry=${country%%:*}
    VALUE=${animal#*:}
    basecountry=$(basename ${country})
    continent=$(dirname ${country})
    TARGETFILE=../${TARGETDIR}/${basecountry}_addresses-nationwide_${continent}.osm.pbf
    MSG="address country ${basecountry} and the continent name ${continent} from ${URL_SUFFIX}${urlpart}"
    
    if [ ! -f $TARGETFILE ]; then
       echo "Skip ${MSG}"
    else
       echo "Generate ${MSG}"
       # As the file was older then 8 days, or non-existent, we download the country again
       wget -O ${basecountry}.osm.pbf -nv "${URL_SUFFIX}${urlpart}"
       # convert to fastest intermediate format
       osmconvert --drop-author ${basecountry}.osm.pbf --out-o5m -o=${basecountry}.o5m
       # filter only the necessary stuff out of the entire osm file
       osmfilter ${basecountry}.o5m --keep="boundary=administrative addr:* place=* is_in=* highway=residential =unclassified =pedestrian =living_street =service =road =unclassified =tertiary" --keep-ways-relations="boundary=administrative" --keep-ways= --keep-nodes= --keep-relations= --out-o5m > ${basecountry}_addresses-nationwide_${continent}.o5m
       # convert back to format suitable for OsmAndMapCreator
       osmconvert ${basecountry}_addresses-nationwide_${continent}.o5m --out-pbf -o=$TARGETFILE
       rm -f ${basecountry}.o5m ${basecountry}_addresses-nationwide_${continent}.o5m
    fi
done
