#!/bin/sh

hugo --contentDir=posts --verbose --verboseLog --destination public --cleanDestinationDir --minify --templateMetrics --templateMetricsHints

#this is the exit

exit $?

