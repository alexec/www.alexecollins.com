---
title: "catalina-restart.sh"
tags: unix,tomcat,gist
---
<p>A short script to stop Tomcat, and then restart it.</p>

	
	#! /bin/sh
	set -eu
	
	while [ $(netstat -na | grep -c 8080) -ne 0 ] ; do
	        echo "Stopping Catalina..."
	        catalina.sh stop
	        sleep 3s
	done
	
	catalina.sh jpda start
