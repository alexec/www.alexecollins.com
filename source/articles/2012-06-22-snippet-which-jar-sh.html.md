---
title: "Snippet: which-jar.sh"
tags: unix,gist
---
<p>I seem to spend a lot of time trying to find files in jars, so I wrote a script a while ago to do this.</p>

	#! /bin/sh
	set -eu
	
	if [ "$*" = "" ] ; then
	        echo "usage: $(basename $0) pattern directory"
	        exit 1
	fi
	
	P=$1 ;# filename pattern to find
	D=$2 ;# directory to search in
	
	for F in $(find $D -type f) ; do
	        jar tf $F | grep $P | sed "s/.*/$(echo $F | tr '/' '\\\\/'):\\0/"
	done
