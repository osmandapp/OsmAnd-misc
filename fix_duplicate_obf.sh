#!/bin/bash
echo Fix duplicate obf in indexes/*.obf.zip
dir=/var/www-download/indexes
if [[ ! -d "$dir/tmp_dup" ]] ; then
	mkdir "$dir/tmp_dup"
fi
rm -rf $dir/tmp_dup/*_2.*
for file in $dir/*.obf.zip ; do
	filename=$(basename $file)
	count_obf=$(unzip -l $file | sed '/.zip/d' | grep obf | wc -l)
	if [[ $count_obf > 1 ]] ; then
		echo "Error! $file contains $count_obf obf files"
		mv $file $dir/tmp_dup
		unzip -d $dir/tmp_dup $dir/tmp_dup/$filename
		echo $dir/${filename} $dir/tmp_dup/${filename%.*}
		cd $dir/tmp_dup
		zip ../${filename} ${filename%.*}
		rm $dir/tmp_dup/*.obf
	fi
done