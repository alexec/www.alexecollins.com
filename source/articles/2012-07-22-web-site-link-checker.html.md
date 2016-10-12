---
title: "Web Site Link Checker"
tags: java,software
---
<p>This is a simple command line application that crawls a website for broken links.</p>

	$ java -jar link-checker-1.0.0-jar-with-dependencies.jar /
	/ broken link to http://www.google.com/search?hl=en&q=allinurl%3Afile+java.sun.com&btnI=I%27m%20F</body></html>: java.net.URISyntaxException: Illegal character in query at index 80: http://www.google.com/search?hl=en&q=allinurl%3Afile+java.sun.com&btnI=I%27m%20F</body></html>
	..
	/http//covestor.com/
	/swing-plaf-example: failed to process link /tutorial-swing-synth-plaf-template-part-1: java.io.FileNotFoundException: /tutorial-swing-synth-plaf-template-part-1
	Done - 39027 ms

<p>The code is <a href="https://github.com/alexec/link-checker">Github</a>.</p>
