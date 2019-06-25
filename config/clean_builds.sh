#!/bin/bash
for f in *-20*; do
    fdate=${f##*-20};
    fdate=${fdate%%.*};
    sc=$(date --date="20$fdate" +%s);
    scnow=$(date +%s);
    if [ ! -z "$sc" ]; then
        dow=$(date --date="20$fdate" +%u);
        # more than 14 days keep 50%
        delete=0;
        if (($scnow - $sc > 14*60*60*24)); then
            delete=$(( $dow == 2 || $dow == 4 || $dow == 7 ));
        elif (($scnow - $sc > 28*60*60*24)); then
            delete=$(( $dow == 2 || $dow == 3 || $dow == 4 || $dow == 6 || $dow == 7 ));
        elif (($scnow - $sc > 90*60*60*24)); then
            delete=$(( $dow == 2 || $dow == 3 || $dow == 4 || $dow == 6 || $dow == 7 ));
        fi
        if (( $delete )); then
            echo "Deleting $f: $dow $fdate";
        fi
    fi
done
