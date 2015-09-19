---
title: Sonarqube And Java 8
date: 2015-09-17 09:23 UTC
tags: java, sonar, jacoco, pitest
---
This article is some tips and help for setting up Java 8 projects for analysis on Sonarqube. My goal is to:

* Have static analysis.
* Have mutation coverage using Pi Test
* Exclude Lombok and XJB generated classes.
* Use Maven.

Firstly, it's important to understand some key things about how the Sonar plugin works.  Sonar does static analysis using built in plugins, but test and mutation coverage require Maven plugins to be set-up. This means you need to configure all the plugins in separately.

Static Analysis
---
If you need to exclude some source file for static analysis (e.g. generated sources) you need to add a Sonar property. Unusually for a Maven plugin, you can only configure Sonar via properties.:

~~~xml
<properties>
    <sonar.exclusions>**/generated-sources/**</sonar.exclusions>
</properties>
~~~

If your generated files are elsewhere, you'll need to change this.

Jacoco
---
Jacoco allows you to gather coverage metrics. It attaches to the JVM when Surefire runs your tests to do this, so you need to tell it prepare an agent:

~~~xml
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <!-- newer versions do not work with Sonar -->
    <version>0.7.4.201502262128</version>
   <executions>
       <execution>
           <phase>initialize</phase>
           <goals>
               <goal>prepare-agent</goal>
           </goals>
       </execution>
   </executions>	    
</plugin>
~~~

[Lombok](https://projectlombok.org) generates code from annotated class. You'd want to exclude this generated code from analysis and from test coverage. Therefore you need to configure both Sonar and Jacoco.

Lombok annotated fields and methods with `@SuppressWarnings("all")`. Jacoco ignores this. It does not support exclusion by annotation. You must do this manually. Here is a script you can use:

~~~xml
<sonar.exclusions>**/generated-sources/**,**/mypackage/MyVO.java/<sonar.exclusions>
~~~
	
You'll need to update this every time you wanted to update this.

PiTest
---
[PiTest](http://pitest.org) is a mutation coverage tool that help you find untested or redundant code. You need to install [the plugin](https://github.com/SonarCommunity/sonar-pitest) into Sonar.

~~~xml
<groupId>org.pitest</groupId>
<artifactId>pitest-maven</artifactId>
<version>1.1.6</version>
<configuration>
    <targetClasses>
    	<!-- it is best to specify which classes you want mutation coverage on -->
        <targetClass>mypackage*</targetClass>
    </targetClasses>
    <targetTests>
    	 <!-- if your project has *IT integration tests, and they are slow, you probably only want to include normal tests -->
        <targetTest>mypackage*Test</targetTest>
    </targetTests>
    <outputFormats>
        <!-- Sonar needs the XML output -->
        <outputFormat>XML</outputFormat>
        <outputFormat>HTML</outputFormat>
    </outputFormats>
    <!-- Sonar expects reports to not have timestamps -->
    <timestampedReports>false</timestampedReports>
</configuration>
</plugin>
~~~

To enable PiTest on Sonar, use this property:

~~~xml
<properties>
    <sonar.pitest.mode>active</sonar.pitest.mode>
</properties>
~~~

Finally, you can create your analysis using:

~~~
mvn clean test sonar:sonar
~~~