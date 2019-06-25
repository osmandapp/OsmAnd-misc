#!/bin/bash
for f in *-20*; do
    fdate=${f##*-20};
    fdate=${fdate%%.*};
    sc=$(date --date="20$fdate" +%s);
    scnow=$(date +%s);
    if [ ! -z "$sc" ]; then
        dow=$(date --date="20$fdate" +%u);
        if (($scnow - $sc > 120*60*60*24)); then
            echo $dow $fdate $f;
        fi
    fi
done
