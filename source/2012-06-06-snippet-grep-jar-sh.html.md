---
title: "Snippet: grep-jar.sh"
---
<p>First draft of a script to grep for string inside jar (i.e. zgrep). I'm pretty sure there's a more elegant way of doing this, but this is functional.</p>

	
	#! /bin/sh
	set -eu
	
	if [ $# -ne 2 ] ; then
	        echo "usage: $(basename $0) pattern path" > /dev/stderr
	        echo "  list the jar, file within the jar, and line in the file, where the line matches the pattern" > /dev/stderr
	        exit 1
	fi
	
	P=$1 ;# pattern
	D=$2 ;# directory
	T1=$TMP/$(basename $0)
	
	for F in $(find "$D" -type f -name '*.jar') ; do
	        echo "examining $F..."
	        rm -Rf $T1
	        mkdir $T1
	        unzip -q "$F" -d "$T1"
	        grep -R "$P" "$T1" || true
	done
