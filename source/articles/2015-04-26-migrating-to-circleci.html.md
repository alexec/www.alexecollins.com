---
title: Migrating to CircleCI
date: 2015-04-26 10:12 UTC
tags: ci, circleci, docker, maven
---
## Oveview
This weekend I've been migrating my builds to [CircleCI](https://circleci.com) from [TravisCI](https://travis-ci.org). 

In this post:

* I'll tell you why I moved.
* What I like about it.
* What problems I had.

So, why would I do this?

* CircleCI has Docker container support, which I really need for my Docker plugin builds.
* CircleCI has great support for JUnit XML reports.
* I need to run integration tests.
* I wanted to reduce the amount of time I spent waiting for integration builds on my laptop to run.

I've found it a pleasant, if time consuming task. I've also been able to take time to improve the builds themselves:

* Support for [Saucelabs](http://saucelabs.com) in my WebDriver builds.
* Run Docker integration tests.
* Deploy snapshots to [Nexus OSS repository](https://oss.sonatype.org).
* Correct my builds together into a pipeline.

### Sharing Build Artefacts

The first problem I encountered wast that I wanted to share artefacts between builds. I thought that this was going to be painful, but I resolved really quickly and securely with Maven. Once you've got your OSS keys set-up, you need to do a couple of things:

1. Create a `settings.xml` to use for your build.
2. Pass the secure settings via environment variables.
3. Use the new `settings.xml` in your `circle.yml`.

You can do this by adding this to the root of your source code:

	<settings xmlns="http://maven.apache.org/SETTINGS/1.1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.1.0 http://maven.apache.org/xsd/settings-1.1.0.xsd">
	    <servers>
	        <server>
	            <id>sonatype-nexus-snapshots</id>
	            <username>${env.SONATYPE_USER}</username>
	            <password>${env.SONATYPE_PASSWORD}</password>
	        </server>
	        <server>
	            <id>sonatype-nexus-staging</id>
	            <username>${env.SONATYPE_USER}</username>
	            <password>${env.SONATYPE_PASSWORD}</password>
	        </server>
	    </servers>
	    <profiles>
	        <profile>
	            <id>gpg</id>
	            <properties>
	                <gpg.passphrase>${env.GPG_PASSPHRASE}</gpg.passphrase>
	            </properties>
	        </profile>
	        <profile>
	            <id>sonatype-staging</id>
	            <repositories>
	                <repository>
	                    <id>sonatype-staging</id>
	                    <url>https://oss.sonatype.org/service/local/staging/deploy/maven2/</url>
	                    <layout>default</layout>
	                    <releases>
	                        <enabled>true</enabled>
	                    </releases>
	                </repository>
	            </repositories>
	        </profile>
	    </profiles>
	    <activeProfiles>
	        <activeProfile>gpg</activeProfile>
	        <activeProfile>sonatype-staging</activeProfile>
	    </activeProfiles>
	</settings>

This externalises the usernames and passwords into environment variables that you can securely add to you build. I use the same `settings.xml` file locally as I do remotely. This means you need to add your them to you `~/.bash_profile`:

	export SONATYPE_USER=secret
	export SONATYPE_PASSWORD=secret
	export GPG_PASSPHRASE=secret
	
You can them update your `circle.yml` do deploy:

	test:
	 override:
	  - mvn deploy -Prun-its -s settings.xml

To complete this the deployment of your artefacts, you need to add your keys into the web interface.

For another build to consume them in another build you just need to add the repository to your `pom.xml`:

    <repositories>
        <repository>
            <id>sonatype-snapshots</id>
            <url>https://oss.sonatype.org/content/repositories/snapshots/</url>
            <snapshots>
                <enabled>true</enabled>
            </snapshots>
        </repository>
    </repositories>

And, if you have a plugin dependency, you'll also need to add that:

    <pluginRepositories>
        <pluginRepository>
            <id>sonatype-snapshots</id>
            <url>https://oss.sonatype.org/content/repositories/snapshots/</url>
            <snapshots>
                <enabled>true</enabled>
            </snapshots>
        </pluginRepository>
    </pluginRepositories>

Finally, you need to tell CircleCI about how to resolve dependencies in `circle.yml`:

	dependencies:
	 override: 
	  - mvn dependency:resolve -s settings.xml

### Multi-module Build Dependencies

By default, CircleCI tries to resolve dependencies before the build. This becomes a problem if you have a multi-module build, as those dependencies will not exist! To fix this, override the set-up to install them locally:

	dependencies:
	 override: 
	  - mvn install -DskipTests     

### Stopping Unwanted Services

One of my builds creates a MySQL Docker container listening on port 3306. But when I ran it on CircleCI, it produced a bind error as MySQL was already running. Stop it as follows (you must use `sudo`):

	test:
	 override:
	  - sudo service mysql stop

### Test Reports

CircleCI can collect test reports in the ubiquitous JUnit format. Just add a few lines to your `circle.yml`:

	test:
	 post:
	  - mkdir -p $CIRCLE_TEST_REPORTS/junit/
	  - find . -type f -regex ".*/target/.*-reports/.*xml" -exec cp {} $CIRCLE_TEST_REPORTS/junit/ \;

This will collect both Surefire and Failsafe reports.

### Removing Docker Containers

I was seeing this error a lot:

	Driver btrfs failed to remove root filesystem 39ae….95ee: Failed to destroy btrfs snapshot: operation not permitted

The Docker set-up does not support removal of containers. You need to hack around this in your build if you need to do it. 

### Creating A Build Pipeline

You can create a build pipeline that starts one build when another finishes. To do this, you can create a script that uses their API. I called mine `circle.sh`:

	#!/bin/bash -ex

	curl -v -X POST https://circleci.com/api/v1/project/alexec/$1/tree/master?circle-token=$CIRCLE_TOKEN

You need to then create an API token and  update the environment variables for your build. Finally, you can kick it off in your `circle.yml`:

	deployment:
	 staging:
	   branch: master
	   commands:
		  - ./circle.sh start_build docker-maven-plugin

## Summary

I've had a really good experience with CircleCI. Particularly, I've found it really fast. There are a few rough edges. If you've come from using Jenkins you may miss its massive ecosystem of plugins.

I've put my [build scripts onto Github](https://github.com/alexec/circleci).
