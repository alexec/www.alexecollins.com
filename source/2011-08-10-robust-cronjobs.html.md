---
title: "Robust Cronjobs"
---
<p>Cron jobs were the bane of my life. They were fragile, unreliable, time consuming to test, hard to fix. If some failed then they were impossible to re-run. No performance metrics were collected and no monitoring was undertaken. Ultimately they were costly to write, and as no one knew what they did, costly to maintain.</p>

<p>Here's some quick tips on writing robust cron jobs.</p>

<ol>
<li>Considering break your app into two parts: one that does the actual work, and a wrapper script one that sets up the environment, adds logging and error handling.</li>
<li>Use the same bash script wrapper and (if possible) configuration on every environment. Otherwise you're not testing the wrapper and you cannot tell if it will worked until you run it in production.</li>
<li>Write the app so that it can take parameters for the time frame it should have run for. This will make it easy to test: you can then test it to see how it would have behaved at various times.</li>
<li>Make it idempotent so you can repeat each test easily, and if it fails, it can safely be re-run.</li>
<li>Consider sourcing ~/.bashrc in your shell wrapper so that your app runs in a similar env in a shell to that when it'll be run by the daemon.</li>
<li>If you develop on one machine (e.g. Linux), and deploy to another (e.g. UNIX), then make sure you take this into account. Try and develop scripts that will run in any environment.</li>
<li>You can test it using "cd && env - myapp" so that it is run in the same working directory and a <I>similar</i> env as when it runs as a cron.
<li>Log output to a log file (e.g. /var/log/$USER/myapp.out), but remember some errors (e.g. stack traces from you apps main thread) are written to stout or stderr. Handily they will be delivered to the user's UNIX mailbox. You set-up ~/.forward so you can also get a copy in your in-box. Make sure the error is helpful, add the hostname and command for example. Don't forget to rotate, compress and archive your logs.</li>
<li>Consider recording reporting metrics from the app. How long it took to run, how many records it processed. These are useful for debugging, and also useful for monitoring performance over longer periods of time, or creating alarms.</li>
<li>Document, but not in some obscure, hard to find and un-maintanable article in your corporate intranet. Perhaps document in a README.txt AND the app's help, which could be accessible using a "-h" option.</li>
</ol>

<p>Here's an simple example:</p>

	#! /bin/sh
	set -eu
	
	function usage {
		echo >&2 "Usage: $0 [-n ndayago]"
	}
	
	while getopts n: o ; do
		case "$o" in
		n)	NDAYSAGO="$OPTARG";;
		[?])	usage
			exit 1;;
		esac
	done
	shift $(($OPTIND-1))
	
	# there's no default for -n, so exit if not set
	if [ -z "${NDAYSAGO:-}" ] ; then usage ; exit 1 ; fi
	
	find $TMPDIR -type f -mtime $NDAYSAGO

<p>To test this, you can try:</p>

	% cd && env - USER=alexec TMPDIR=$TMPDIR /Users/$USER/bin/find-changed-in-tmp.sh -n 1 > /var/log/$USER/find-changed-in-tmp.$(date +%Y-%m-%d).out

<p>Note that I need to add the USER and TMPDIR as "env -" will erase them. The resulting crontab entry is:</p>

	38 3 * * * /Users/$USER/bin/find-changed-in-tmp.sh -n 1 >> /var/log/$USER/find-changed-in-tmp.$(date +\\%Y-\\%m-\\%d).out 

<p>Note that I have to escape the percentage symbols, and that I append to the log file so re-runs won't erase the old logs.</p>

<p>If you enjoyed this post, you might be interested in <a href="/content/tips-robust-bash-scripts">this one on robust scripts</a>.</p>
