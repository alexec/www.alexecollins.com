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
I'm going to assume you have Docker installed and running. If you're on OS-X, and using boot2docker, then you'll need to [set-up port forwards](/content/first-steps-with-docker).

The project has an example which creates a container that run a standalone JAR ([they're so hot right now!](http://martinfowler.com/articles/microservices.html)) in [it's tests](https://github.com/alexec/docker-maven-plugin/tree/master/src/it/build-test-it). 

Checkout the code and quickly build it and run the tests:

~~~
git clone https://github.com/alexec/docker-maven-plugin
mvn install -Prun-its
~~~

You'll have the example ready to examine:

~~~
$ cd target/it/build-test-it/
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

	$ java -jar target/example-1.0-SNAPSHOT.jar db migrate hello-world.yml
	Can not read response from server. 

It's failed to run - that's not very impressive! That's because, you need a MySQL server running on port 3306, to set-up the database. Lets use the plugin to build this for us:

	$ mvn docker:package
	..
	$ docker ps -a|grep mysql
	2154b8780ad9        0b5620021ade          /usr/bin/mysqld_safe   8 minutes ago       Exit 137                                example_app/example_mysql,example_mysql 

There we go, a set-up and configured container which we can start:

	$ docker run -i -i -p 3306:3306 -name example_mysql example_mysql

Now we need to set-up the database:

	$ java -jar target/example-1.0-SNAPSHOT.jar db migrate hello-world.yml
	...
	$ java -jar target/example-1.0-SNAPSHOT.jar server hello-world.yml

Now lets test it, at [http://localhost:8080/hello-world](http://localhost:8080/hello-world) you should see:

~~~json
{"id":1,"content":"Hello, Stranger!"}
~~~

Great! Lets have a look and the config is `src/main/docker`. Each sub-directory is for a single container. There are at least two files in each, a `Dockerfile`, which should not container any surprises:

	FROM centos
	
	RUN yum -y install java-1.7.0-openjdk-devel.x86_64
	
	ADD example-1.0-SNAPSHOT.jar /
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
    - target/example-1.0-SNAPSHOT.jar
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
	
	java -jar example-1.0-SNAPSHOT.jar db migrate hello-world.yml
	java -jar example-1.0-SNAPSHOT.jar server hello-world.yml

Docker reveals the exposed ports of a linked container as environment variables. As the plugin uses the container name as the alias, we can `sed` it into place. 
	
The plugin does more than just building containers. It'll start and stop them for tests too. You can try this out yourself:

	$ mvn clean install
	...
	-------------------------------------------------------
	 T E S T S
	-------------------------------------------------------
	Running com.example.helloworld.HelloWorldServiceIT
	...
	[INFO] BUILD SUCCESS
	...

Horay! We've created a tested docker image ready to be pushed to a repository and deployed!

	$ docker commit example_app alexec/example_app
	$ docker push alexec/example_app

Credits
---
Credit where credit is due: [kyelykh's docker-java library.](https://github.com/kpelykh/docker-java)