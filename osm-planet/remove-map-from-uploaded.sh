#!/bin/bash
if [ -n "$1" ]; then
	rm /var/lib/jenkins/indexes/uploaded/*$1*.obf.zip || echo "true"
fi