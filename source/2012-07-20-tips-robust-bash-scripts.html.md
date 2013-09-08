---
title: "Tips For Robust Bash Scripts"
tags: unix
---

<p>Here are a couple of quick tips for writing more robust shell scripts from my last 10 years of working with bash.</p>

<h2>Tip 1: Use "set -e"</h2>

<p>This will cause your script to exit if an error occurs.</p>

	#! /bin/sh
	set -e
	
	false ;# ops! exit here

<p>If errors are OK, you can add "|| true" so that it'll continue.</p>

	#! /bin/sh
	set -e
	
	false || true ;# this is OK

<h2>Tip 2: Use "set -eu"</h2>

<p>This means your script will exit  if variables are not set, example:</p>

	echo $FOO ;# ops, $FOO not defined

<p>You can provide defaults...</p>

	echo ${FOO:-'default'} ;# this is OK

<h2>Tip 3: Quote All Strings</h2>

<p>You never know when an empty string  will sneak in and break your script.</p>

	% F=""
	% if [ $F == "" ] ; then echo "F is blank"; fi
	-bash: [: ==: unary operator expected

<h2>Tip 4: Consider "find/while" Rather Than "for/find"</h2>

<p>This is tolerant to spaces; and it's faster. This paradigm can be used is similar scenarios.</p>

	% for F in $(find . -type f) ; do echo $F; done
	...
	./win
	file.txt
	...

	% find . -type f | while read F ; do echo $F ; done
	...
	./win file.txt

<p>If you enjoyed this post, perhaps you'd enjoy <a href="/content/robust-cronjobs">this post on robust cron-jobs</a>.</p>
