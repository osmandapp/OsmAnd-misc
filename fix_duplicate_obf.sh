#!/bin/bash
dir=/var/lib/jenkins/indexes/uploaded/
if [[ ! -d "$dir/tmp_dup" ]] ; then
        mkdir "$dir/tmp_dup"
fi
rm -rf $dir/tmp_dup/*.obf
rm -rf $dir/tmp_dup/*.zip
for file in $dir/*.obf.zip ; do
        filename=$(basename $file)
        count_obf=$(unzip -l $file | sed '/.zip/d' | grep obf | wc -l)
        if [[ $count_obf > 1 ]] ; then
                echo "Error! $file contains $count_obf obf files"
                mv $file $dir/tmp_dup
                unzip -d $dir/tmp_dup $dir/tmp_dup/$filename
                cp $dir/tmp_dup/${filename%.*} $dir/../
                rm $dir/tmp_dup/*.obf
        fi
done
rmdir "$dir/tmp_dup"