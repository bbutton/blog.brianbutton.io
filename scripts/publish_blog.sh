#!/bin/bash

FORCE=0
PUBLISH_NEEDED=0

if  test "$1" == "--force" -a $# -ne 3 || test $# -ne 2; then
	echo "usage: $0 [--force] <contentDir> <destinationDir>" >&2
	exit 1
fi

if [ "$1" == "--force" ]; then 
	FORCE=1
	PUBLISH_NEEDED=1
	shift
fi

if [ $FORCE -eq 0 ]; then 
	git remote -v update 2>&1 | grep "up to date" | grep -q master
	if [ $? -ne 0 ]; then
		echo "Changed detected, updating blog source before publishing"
		git pull
		PUBLISH_NEEDED=1
	else
		echo "No changes detected, blog not updated"
	fi
fi

if [ $PUBLISH_NEEDED -eq 1 ]; then
	echo "Publishing new blog to $2"
	hugo --verbose --verboseLog --contentDir $1 --destination $2 --cleanDestinationDir --minify --templateMetrics --templateMetricsHints
fi

exit 0
