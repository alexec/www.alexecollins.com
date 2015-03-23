---
title: Polyglot Maven First Steps
date: 2015-03-23 08:17 UTC
tags: maven, java, groovy, ci
---
## Overview

I read with keen interest about [Polyglot Maven](http://www.infoq.com/news/2015/03/maven-polyglot) a few days ago. I'd first heard rumors two years ago, but I thought it was dead. I thought it was a shame, and so  tried to created a [project](https://github.com/alexec/mvn.json) which would process `pom.json` files. But I ceased working on it as turned out to be time consuming.

Maven `pom.xml` files are very verbose, and yet Gradle has not quite taken off. Would a `pom.groovy` fill the space? Lets find out!

# Prerequisites

Before you start, you must have Maven 3.3.1 installed. This has support for ["Core Extension"](http://blog.soebes.de/blog/2015/03/17/apache-maven-3-dot-3-1-features/).

# Example

Firstly, create a sample application:

~~~bash
mvn archetype:generate \
	-DgroupId=test \
	-DartifactId=test-webapp \
	-Dversion=1.0.0-SNAPSHOT \
	-DarchetypeArtifactId=maven-archetype-webapp
cd test-webapp
~~~
	
Set-up the Maven extensions:

~~~bash
mkdir .mvn
cat > .mvn/extensions.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<extensions>
    <extension>
        <groupId>io.takari.polyglot</groupId>
        <artifactId>polyglot-groovy</artifactId>
        <version>0.1.6</version>
    </extension>
</extensions>
EOF
~~~

Maybe make it a bit more of a challenge, add the Jetty and Failsafe plugins:

~~~xml
<plugin>
    <groupId>org.eclipse.jetty</groupId>
    <artifactId>jetty-maven-plugin</artifactId>
    <version>9.2.3.v20140905</version>
    <configuration>
        <stopPort>9966</stopPort>
        <stopKey>foo</stopKey>
    </configuration>
    <executions>
        <execution>
            <id>start</id>
            <phase>pre-integration-test</phase>
            <goals>
                <goal>start</goal>
            </goals>
        </execution>
        <execution>
            <id>stop</id>
            <phase>post-integration-test</phase>
            <goals>
                <goal>stop</goal>
            </goals>
        </execution>
    </executions>
</plugin>
<plugin>
    <artifactId>maven-failsafe-plugin</artifactId>
    <version>2.17</version>
    <executions>
        <execution>
            <goals>
                <goal>integration-test</goal>
                <goal>verify</goal>
            </goals>
        </execution>
    </executions>
</plugin>
~~~

Then, convert the pom into Groovy:

~~~bash
mvn io.takari.polyglot:polyglot-translate-plugin:translate -Dinput=pom.xml -Doutput=pom.groovy
rm pom.xml
~~~

You can add some Groovy into the `pom.groovy` at the end of the build section:

~~~groovy
$execute(id: 'hello', phase: 'verify') {
  println ""
  println "Hello! I am Groovy inside Maven. What? What am I doing here?? I'm confused. I guess we are friends now. Maybe."
  println ""
} 
~~~

Now for the big show!

~~~bash
mvn verify
~~~

# Summary

AFAIK, there is zero IDE support for non-XML poms. But... here is an amusing work-around...

~~~groovy
plugin {
    groupId 'io.takari.polyglot'
    artifactId 'polyglot-translate-plugin'
    executions {
        execution {
            id 'create-pom-for-ide'
            phase 'generate-sources'
            goals {
                goal 'translate'
            }
            configuration {
                input 'pom.groovy'
                output 'pom.xml'
            }
        }
    }
}
~~~

This is an interesting development in the Maven eco-system. It is certainly a lot of fun to play around with.