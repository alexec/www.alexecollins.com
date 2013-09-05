---
title: "Executing Groovy in ColdFusion"
---
<p>There's plenty of articles on loading Java in CF, but none for Groovy. Here's my guide.</p>
<p>This first piece of code creates a persistent class loader (in  Application.cfc/onApplicationStart):</p>

	<cfscript>
		application.groovyClassLoader = createObject("java", "groovy.lang.GroovyClassLoader").init();
		l = directoryList(expandPath("lib"));
		for (i = 0; i < l.size(); i++) {
		application.groovyClassLoader.addClasspath(l.get(i));
		}
	</cfscript>
<p>The second is a function to load & instantiate Groovy classes:</p>
	<cfscript>
		function loadGroovyFile(groovyFile) {
			fl = CreateObject("java", "java.io.File").Init(JavaCast("String", groovyFile));
			return application.groovyClassLoader.parseClass(fl).newInstance();
		}
	</cfscript>

You'll need to copy the groovy-all jar into CF's lib directory (/usr/local/coldfusion/lib) and restart CF so that it's aware of it.

Next, a Groovy class (HelloWorld.groovy):

	class HelloWorld {
	    String sayHello() {
	        return "Hello World!"
	    }
	}

Finally you can create a .cfm page (e.g. HelloWorld.cfm):

	<cfset hw = loadGroovyFile("HelloWorld.groovy")>
	<cfoutput>#hw.sayHello()#</cfoutput>
