---
title: Gatling is 5 Minutes
date: 2013-10-26 08:12 UTC
tags: perfromance,testing,maven,vagrant,gatling
---
This is a tutorial that will get you up and running with Gatling load testing tool, as well as a Vagarant image running Graphite so you can monitor your tests in real-time.

Step 1 - Install Graphite

	git clone https://github.com/Jimdo/vagrant-statsd-graphite-puppet
	cd vagrant-statsd-graphite-puppet
	
This sets up a port forward on 8080, but I want to use that for the app to be tested, so lets up date it:

	sed 's/8080/8081/' Vagrantfile > Vagrantfile.1
  	mv Vagrantfile.1 Vagrantfile

Now we can start it:

	vagrant up

And as it takes a couple of minutes to download and start, you can check Graphite is running: [http://localhost:8081](http://localhost:8081), and you should see something like this:


<%=thumbnail_url('graphite-no-data.png', 'small'))%>
	
Step 2 - Run a Test App

I'm using Maven, so an off the shelf archetype will save time.	

	echo Y | mvn archetype:generate -DgroupId=test -DartifactId=test-webapp -Dversion=1.0.0-SNAPSHOT -DarchetypeArtifactId=maven-archetype-webapp
	cd test-webapp
	mvn org.mortbay.jetty:maven-jetty-plugin:run

Again, this will take a minute or two to download and start up.

Step 3 - Download and Run Gatling

Download Gatling (I'll use the latest stable, 1.5.2): from their website:

	https://github.com/excilys/gatling/wiki/Downloads




	
	
	
References:

* [Creating a Maven webapp from scratch](http://nofail.de/2010/03/creating-a-maven-webapp-from-scratch/)