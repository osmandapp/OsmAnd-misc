#!/bin/bash
DIRECTORY=$(cd `dirname $0` && pwd)
mkdir $DIRECTORY/publish
echo '"shared_folders" : ['
for f in "*"	
do
  SECRET=`$DIRECTORY/btsync --generate-secret`
  RO_SECRET=`$DIRECTORY/btsync --get-ro-secret $SECRET`
  echo "{ \"secret\": \"$SECRET\", \"dir\": \"$DIRECTORY/$f\", \"ro-secret\" : \"$RO_SECRET\"}"
done
echo ']'