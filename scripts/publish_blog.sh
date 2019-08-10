#!/bin/bash

if [ $# -ne 2 ]; then
	echo "usage: $0 <contentDir> <destinationDir>" >&2
	exit 1
fi

git remote -v update 2>&1 | grep "up to date" | grep -q master
if [ $? -ne 0 ]; then
	echo "Changed detexted, updating blog source before publishing"
	git pull
	hugo --verbose --verboseLog --contentDir $1 --destination $22 --cleanDestinationDir --minify --templateMetrics --templateMetricsHints
else
	echo "No changes detected, blog not updated"
fi
