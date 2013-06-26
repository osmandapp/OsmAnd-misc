#!/bin/bash
DIRECTORY=$(cd `dirname $0` && pwd)
mkdir -p $DIRECTORY/publish
cat  $DIRECTORY/server_template.config
# echo '"shared_folders" : ['
for f in *
do
  SECRET=`$DIRECTORY/btsync --generate-secret`
  RO_SECRET=`$DIRECTORY/btsync --get-ro-secret $SECRET`
  echo "{ \"secret\": \"$SECRET\", \"dir\": \"$DIRECTORY/publish/$f\", \"ro-secret\" : \"$RO_SECRET\" \"use_relay_server\" : true,\"use_tracker\" : true,  \"use_dht\" : true,\"search_lan\" : true}, "
done
echo '] }'