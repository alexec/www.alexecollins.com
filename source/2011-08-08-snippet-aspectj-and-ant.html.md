---
title: "Snippet: AspectJ and Ant"
---
<p>I've just started working with AspectJ and despite its non-intuitive syntax, I'm pretty sold on its effectiveness at reducing development time and complexity by factoring out crosscutting concerns such as logging and security. However, the Internet is a little lacking in guides and how to build it, so here's my how to. </p>

<p>1) Download AspectJ tools jar and save this into your ~/.ant/lib directory. </p>

<p>2) Add the XML namespace to the project element:</p>

	
	<p>Create a new compile target in your build.xml (you can see that I use Ivy for dependency management):</p>
			&lt;mkdir dir="${build}" /&gt;
			&lt;aspectj:iajc source="1.6" destDir="${build}"&gt;
				&lt;sourceroots&gt;
					&lt;pathelement location="${src}" /&gt;
				&lt;/sourceroots&gt;
				&lt;classpath&gt;
					&lt;fileset dir="${lib}"&gt;
						&lt;include name="**/*.jar" /&gt;
					&lt;/fileset&gt;
				&lt;/classpath&gt;
			&lt;/aspectj:iajc&gt;
		&lt;/target&gt;

<p>Note: you may need to tell AspectJ to use target Java 6.</p>

<p>3) Factor out the javac element into it's own "compile.javac" task, this will allow you to revert to javac easily:</p>

			&lt;mkdir dir="${build}" /&gt;
			&lt;javac srcdir="${src}" destdir="${build}" includeantruntime="false"&gt;
				&lt;classpath&gt;
					&lt;fileset dir="${lib}"&gt;
						&lt;include name="**/*.jar" /&gt;
					&lt;/fileset&gt;
				&lt;/classpath&gt;
			&lt;/javac&gt;
		&lt;/target&gt;

<p>4) Make the "compile" target dependent on "compile.aspectj";</p>

			&lt;copy todir="${build}"&gt;
				&lt;fileset dir="${src}" excludes="**/*.java" /&gt;
			&lt;/copy&gt;
		&lt;/target&gt;

<p>5) Build it.</p>

<p>You might want to also download the AspectJ runtime in your build (e.g. using Ivy). </p>
