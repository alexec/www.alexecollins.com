---
title: First steps with Docker
date: 2014-03-09 18:56 UTC
tags: docker, vagrant, drop-wizard
---
[Docker](http://www.docker.io) has been getting a lot of good press recently. It's a lightweight container environment running on Linux that is like a low-fat version of [Vagrant](http://www.vagrantup.com). I thought it was time to try my hand.

Docker is different to Vagrant. 

| **Vagrant**   | **Docker**       |
| Dev           | Dev & Production |
| Persistent    | Disposable       |
| Many apps     | Single app       |
| Ruby          | Bash             |

The Install
---
This is a yum/apt online on Linux. But, I'm on Mac. Several Mac tutorials use Vagrant to run Docker. 

Alternatively, Docker can be run more transparently using boot2docker:

	brew install boot2docker
	boot2docker init
	boot2docker up
	export DOCKER_HOST=tcp://localhost:4243

You should be able to check the version now:

	docker version
	
Your First Container
---
The steps I've seen over and over again are the ones I'll use here:

1. Create an base image from one of the main Linux images.
2. Install some dependencies and your app.
3. Expose the app on a port.
4. Save it.

I've created a simple app to start, which can be run from the command line:

	git clone https://github.com/alexec/dropwizard-helloworld.git
	mvm package
	
Create `Dockerfile` in the project directory:

	FROM centos
	
	RUN yum -y install java-1.7.0-openjdk-devel.x86_64 
	
	ADD target/dropwizard-helloworld-1.0-SNAPSHOT.jar /
	ADD hello-world.yml /
	
	CMD ["java", "-jar", "dropwizard-helloworld-1.0-SNAPSHOT.jar", "server", "hello-world.yml"]
	
	EXPOSE 8080
	
The `Dockerfile` is an all in one recipe, and that complete all the steps:

	docker build .

When it's complete, it'll print a hash for the **image** it's built:

	Successfully built a3e6a912822c
	
It's important to understand there's a big difference between an **image** and a **container** hash. They look the same, and as commands you might expect to take a container ID sometimes take an image ID.

Start it up:

	docker run -i -P a3e6a912822c
	
Note the `-P` option, that creates the port forwards from the host OS to the container. Which port is it? It's not the exposed port (8080) as you might expect. Docker chooses a port for you, and you can see which port it is:

	$ docker ps
	CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS                     NAMES
	67079fc70d31        a3e6a912822c        java -jar dropwizard   9 days ago          Up About a minute   0.0.0.0:49155->8080/tcp   compassionate_tesla  

As I'm running Docker within a VM (as I'm on OS-X), I need to set-up a port forward from my computer to the VirtualBox that boot2docker uses:

	VBoxManage controlvm boot2docker-vm natpf1 "49155,tcp,127.0.0.1,49155,,49155"
	
You can test in your browser: [http://localhost:49155/hello-world](http://localhost:49155/hello-world)
	
Tip: Really useful debugging command (like `vagrant ssh`):

	docker run -i -t a3e6a912822c bash
	
	

