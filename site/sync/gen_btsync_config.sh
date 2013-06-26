#!/bin/bash
DIRECTORY=$(cd `dirname $0` && pwd)
mkdir -p $DIRECTORY/publish
cat  $DIRECTORY/server_template.config
RUN_IN=`pwd`
# echo '"shared_folders" : ['
for f in *
do
  if [ -d "$RUN_IN/$f" ]
  then
  	SECRET=`$DIRECTORY/btsync --generate-secret`
  	RO_SECRET=`$DIRECTORY/btsync --get-ro-secret $SECRET`
  	echo "{ \"secret\": \"$SECRET\", \"dir\": \"$RUN_IN/$f\", \"ro-secret\" : \"$RO_SECRET\" \"use_relay_server\" : true,\"use_tracker\" : true,  \"use_dht\" : true,\"search_lan\" : true}, "
  fi
done
echo '] }'