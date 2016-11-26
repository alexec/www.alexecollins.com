---
title: Docker Maven Plugin
date: 2014-04-02 08:24 UTC
tags: docker, maven
---
I've been beavering away for the last few days to create the missing Maven plugin for Docker. I'd previously created a plugin for VirtualBox that manages the creation of virtual machines. Based my ideas on that worked well there (configuration files, templates) but without the ones that don't (XML, patch files, building base boxes). 

What does it add to vanilla Docker?
---
While Docker makes it easy to create containers and set them up, it provides little in the way of orchestration of multiple containers, that is left up to you to do. 

This plugin will, based on some YAML config and Dockerfile's, build your containers, expose ports onto the host, link them together and start/stop them for your integration tests, all in concert.

Think of it as a mixture of a packaging program with a bit of the Cargo plugin thrown in.

What doesn't it add?
---
Anything the `docker` command will do for you. E.g. if you want to attach to a container, start or start a single container, you can do that with the docker command. No need to re-invent that.

Sounds great! How about a short tutorial?
---
The project has an example which creates a container that run a standalone JAR ([they're so hot right now!](http://martinfowler.com/articles/microservices.html)) in [here](https://github.com/alexec/drop-wizard-in-a-box). 

Checkout the code and quickly build it and run the tests:

~~~
git clone https://github.com/alexec/drop-wizard-in-a-box.git
cd drop-wizard-in-a-box
mvn install -Prun-its
~~~

You'll have the example ready to examine:

~~~
$ find . -type f
./hello-world.yml
./pom.xml
./src/main/docker/app/conf.yml
./src/main/docker/app/Dockerfile
./src/main/docker/app/run.sh
./src/main/docker/data/conf.yml
./src/main/docker/data/Dockerfile
./src/main/docker/mysql/conf.yml
./src/main/docker/mysql/Dockerfile
./src/main/java/com/example/helloworld/HelloWorldConfiguration.java
./src/main/java/com/example/helloworld/HelloWorldResource.java
./src/main/java/com/example/helloworld/HelloWorldService.java
./src/main/java/com/example/helloworld/model/Person.java
./src/main/java/com/example/helloworld/PeopleDAO.java
./src/main/java/com/example/helloworld/Saying.java
./src/main/java/com/example/helloworld/TemplateHealthCheck.java
./src/main/resources/migrations.xml
...
~~~

What have we got here? It's a pretty simple Drop-Wizard Hello World Micro-Service. Or in more simple words, it's a standalone JAR that run a REST service. It's adapted from the [example in the documentation](https://dropwizard.github.io/dropwizard/getting-started.html).

Our app needs it's database set-up, so run this:

	$ java -jar target/drop-wizard-in-a-box-1.0.0-SNAPSHOT.jar db migrate hello-world.yml
	Can not read response from server. 

It's failed to run - that's not very impressive! That's because, you need a MySQL server running on port 3306, to set-up the database. Lets use the plugin to build this for us:

	$ mvn docker:package
	..
	$ docker images | head
    REPOSITORY                                                   TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
    registry/drop-wizard-in-a-box-app                            1.0.0-SNAPSHOT      76614734bdcd        3 minutes ago       461 MB

There we go, a set-up and configured container which we can start:

	$ docker run -i -p 3306:3306 registry/drop-wizard-in-a-box-mysql:1.0.0-SNAPSHOT

Now we need to set-up the database:

	$ java -jar target/drop-wizard-in-a-box-1.0.0-SNAPSHOT.jar db migrate hello-world.yml
	...
	$ java -jar target/drop-wizard-in-a-box-1.0.0-SNAPSHOT.jar server hello-world.yml

Now lets test it, at <http://localhost:8080/hello-world> you should see:

~~~json
{"id":1,"content":"Hello, Stranger!"}
~~~

Great! Lets have a look and the config is `src/main/docker`. Each sub-directory is for a single container. There are at least two files in each, a `Dockerfile`, which should not container any surprises:

	FROM dockerfile/java:oracle-java7
	
	ADD ${project.build.finalName}.jar /
	ADD hello-world.yml /
	ADD run.sh /
	
	RUN chmod +x run.sh
	
	CMD ["./run.sh"]
	
	EXPOSE 8080
	EXPOSE 8081

The second file is `conf.yml`, lets take a closer look:

~~~yaml
packaging:
  add:
    - target/${project.build.finalName}.jar
    - hello-world.yml
ports:
  - 8080
links:
  - mysql
~~~
 
This is additional config needed to create and start the container. It's a bit like a recipe. Look at the ingredients:

* `package/add` is a list of additional files to use for our container, in this case, we add the JAR file and some YAML config.
* `ports` is a list of port to expose on the host. Ports are exposed by default between containers.
* `links` is a list of linked containers.

The hawk-eyed amongst you will have noticed that `run.sh` is also in the directory. Lets look at that.

	#!/bin/sh
	set -eux
	
	sed -i "s/localhost:3306/$EXAMPLE_MYSQL_PORT_3306_TCP_ADDR:3306/" hello-world.yml
	
	java -jar ${project.build.finalName}.jar db migrate hello-world.yml
	java -jar ${project.build.finalName}.jar server hello-world.yml

Docker reveals the exposed ports of a linked container as environment variables. As the plugin uses the container name as the alias, we can `sed` it into place. 
	
The plugin does more than just building containers. It'll start and stop them for tests too. You can try this out yourself:

	$ mvn verify
	...
	-------------------------------------------------------
	 T E S T S
	-------------------------------------------------------
	Running com.example.helloworld.HelloWorldServiceIT
	...
	[INFO] BUILD SUCCESS
	...

Horay! We've created a tested docker image ready to be pushed to a repository and deployed!

	$ mvn docker:push
