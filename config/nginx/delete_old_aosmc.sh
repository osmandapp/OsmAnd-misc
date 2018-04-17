#!/bin/bash
dir="$1"  #/home/xmd5a/sshfs/jenkins@builder.osmand.net/mnt/home-ssd/osm-planet/aosmc/argentina_chaco_southamerica/
# timedatectl status | grep "NTP synchronized: yes" > /dev/null
# ntp_status=$(echo $?)
echo $dir
sleep 100000
delete_files()
{
        if [[ -d "$dir" ]]; then
#               echo NTP is ok
                echo ========== $(date)
                echo Removing old files and folders in $dir
                find $dir -maxdepth 2 -type f \( -name "*.gz" -o -name "totalsize" \) ! -name "*_00.obf.gz" -mtime +95 -exec echo {} \; -exec rm {} \;
                find $dir -maxdepth 2 -type f -name "*_00.obf.gz" -mtime +365 -exec echo {} \; -exec rm {} \;
                find $dir -type d -empty -delete -exec echo {} \;
                echo ========== $(date)
#       else echo NTP is not ok
        fi
}
delete_files # > delete_aosmc_log.txt