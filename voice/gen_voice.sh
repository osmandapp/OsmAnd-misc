#!/bin/sh
mkdir -p work
cd work
rm *.wav
festival -b ../fest.$1
for t in `ls *.wav` ; do oggenc $t ; done
rm *.wav
zip $1.zip *.ogg
rm *.ogg