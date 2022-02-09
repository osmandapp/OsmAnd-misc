#!/bin/bash
OSM=$1
REL1=$2
REL2=$3
RES=$4

function combine() {
    LN2=$(grep -n -m 1 "<relation id=\"$REL2\">" $OSM | awk -F':' '{print $1}')
    LN1=$(grep -n -m 1 "<relation id=\"$REL1\">" $OSM | awk -F':' '{print $1}')
    #echo $LN1 --- $LN2
    
    awk "NR==$LN1{ print; exit }" $OSM
    i=$(($LN1+1))
    while [ $i -gt 0 ]
    do    
        line=`awk "NR==$i{ print; exit }" $OSM`
        #echo $line
        lang=`echo $line | grep "<tag k=\"name:" | awk -F'"' '{print $2}'`
        val=`echo $line | grep "<tag k=\"name:" | awk -F'"' '{print $4}'`
        if [ ! -z "$lang" ]
        then
            #echo $lang -- $val
            j=$(($LN2+1))
            while [ $j -gt 0 ]
            do
                line_j=`awk "NR==$j{ print; exit }" $OSM`
                lang_j=`echo $line_j | grep "<tag k=\"name:" | awk -F'"' '{print $2}'`
                val_j=`echo $line_j | grep "<tag k=\"name:" | awk -F'"' '{print $4}'`
                if [ "$lang" == "$lang_j" ]; then
                    echo "    <tag k=\"$lang\" v=\"$val, $val_j\"/>"
                fi
                if [[ $line_j == *"</relation>"* ]]; then
                    j=0
                else
                    j=$((j+1))
                fi
            done
        fi
        if [[ $line == *"</relation>"* ]]; then
            i=0
        else
            i=$((i+1))
        fi
    done
    echo "  </relation>"
    
}

combine >> $RES

