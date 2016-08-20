#!/bin/bash
for file in /var/www-download/indexes/*.zip ; do
	count_obf=$(unzip -l $file | sed '/.zip/d' | grep obf | wc -l)
	if [[ $count_obf > 1 ]] ; then
		echo "Error! $file contains $count_obf obf files"
	fi
done