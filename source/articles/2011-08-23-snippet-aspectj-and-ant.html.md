---
title: "Snippet: AspectJ and Ant"
tags: apsectj, ant
---
<p>I've just started working with AspectJ and despite its non-intuitive syntax, I'm pretty sold on its effectiveness at reducing development time and complexity by factoring out crosscutting concerns such as logging and security. However, the Internet is a little lacking in guides and how to build it, so here's my how to. </p>

<p>1) Download AspectJ tools jar and save this into your ~/.ant/lib directory. </p>

<p>2) Add the XML namespace to the project element:</p>

<p>Create a new compile target in your build.xml (you can see that I use Ivy for dependency management):</p>

	<aspectj:iajc source="1.6" destDir="${build}">
		<sourceroots>
			<pathelement location="${src}" />
		</sourceroots>
		<classpath>
			<fileset dir="${lib}">
				<include name="**/*.jar" />
			</fileset>
		</classpath>
	</aspectj:iajc>


<p>Note: you may need to tell AspectJ to use target Java 6.</p>

<p>3) Factor out the javac element into it's own "compile.javac" task, this will allow you to revert to javac easily:</p>


	<javac srcdir="${src}" destdir="${build}" includeantruntime="false">
		<classpath>
			<fileset dir="${lib}">
				<include name="**/*.jar" />
			</fileset>
		</classpath>
	</javac>

<p>4) Make the "compile" target dependent on "compile.aspectj";</p>

	<copy todir="${build}">
		<fileset dir="${src}" excludes="**/*.java" />
	</copy>

<p>5) Build it.</p>

<p>You might want to also download the AspectJ runtime in your build (e.g. using Ivy). </p>
