#!/bin/bash
extract () {
	osmconvert /home/osm-planet/$2.o5m -B=$1.poly -o=$1.o5m
	echo Extracting $1 from $2
}

extract europe planet-latest
extract great-britain europe
extract east-europe europe
extract south-europe europe
extract north-europe europe
extract west-europe europe
extract france west-europe
extract germany west-europe

extract russia planet-latest
extract asia planet-latest
extract east-asia asia
extract ocean-asia asia

extract central-america planet-latest
extract south-america planet-latest
extract north-america planet-latest
extract us north-america
extract us-northcentral us
extract us-northeast us
extract us-south us
extract us-west us
extract canada north-america

extract africa planet-latest
extract australia-oceania-all planet-latest
