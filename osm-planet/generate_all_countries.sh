#!/bin/bash
cd /home/osm-planet/osm-extract/
for DEP in $(seq 6); do
	echo "DEPTH $DEP"
	for D in $(find * -type d); do
    	DEPTH=$(cat $D/.depth)
    	if [ "$DEPTH" == "$DEP" ]; then
          if [ -f $D/.map ]; then
          	if [ "$REGENERATE" == "true" ] || [ ! -f $D/$D.pbf ] then 
             echo $D
             if [ -f $D/.polyextract ]; then
             	 PARENT=$(cat $D/.polyextract)
        		 FLD=/home/osm-planet/osmc/
                 time osmconvert $FLD/$PARENT.o5m --complex-ways --complete-ways -B=$D/$D.poly -o=$D/$D.pbf
             else 
            	 PARENT=$(cat $D/.parent)
            	 FLD=/home/osm-planet/osm-extract/
                 time osmconvert $FLD/$PARENT/$PARENT.pbf --complex-ways --complete-ways -B=$D/$D.poly -o=$D/$D.pbf
             fi
             chgrp www-data $D/$D.pbf
             chmod g+rw $D/$D.pbf
           fi
          fi   
        fi
    done
done
