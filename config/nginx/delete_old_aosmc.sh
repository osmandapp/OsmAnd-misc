#!/bin/bash
dir=$1 #/home/osm-planet/osmlive
delete_files()
{
        if [[ -d "$dir" ]]; then
                echo ========== $(date)
                echo Removing old files and folders in $dir
                find $dir -maxdepth 3 -type f \( -name "*.gz" -o -name "totalsize" \) ! -name "*_00.obf.gz" -mtime +95 -exec echo {} \; -exec rm {} \;
                find $dir -mindepth 3 -type f -name "*_00.obf.gz" -exec echo {} \; -exec rm {} \;
                find $dir -maxdepth 2 -type f -name "*_00.obf.gz" -mtime +365 -exec echo {} \; -exec rm {} \;
                find $dir -type d -empty -delete -exec echo {} \;
                echo ========== $(date)
        fi
}
delete_files > $dir/delete_aosmc_log.txt
