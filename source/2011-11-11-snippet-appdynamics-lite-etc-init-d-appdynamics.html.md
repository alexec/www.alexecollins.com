---
title: "Snippet: AppDynamics Lite /etc/init.d/appdynamics"
---
<p>More for personal reference than anything else. I'm using it with ColdFusion. It could do with some tweaks (e.g. making sure it started, and stopped).</p>

	#! /bin/sh
	
	N="AppDynamics Viewer"
	D="/home/AppDynamicsLite/LiteViewer"
	C="java -jar adlite-viewer.jar"
	U=appdynamics
	P=$(ps -fu $U|grep -F "$C"|awk '{print $2'})
	
	cd $D
	
	case "$1" in
	start)
		if [ -z "$P" ] ; then 
			echo "Starting $N ..."
			su $U -c "nohup $C" &
		else 
			echo "$N already running (pid=$P)"
		fi
		;;
	stop)
		if [ ! -z "$P" ] ; then 
			echo "Stopping $N (pid=$P) ..."
			kill $P
		else 
			echo "$N not running"
		fi
		;;
	restart)
		$0 stop
		$1 start
	esac
