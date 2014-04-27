---
title: Docker on Amazon AWS
date: 2014-04-26 19:47 UTC
publish: false
tags: docker, amazon, aws, centos
---
This is a short tutorial about getting Docker running on AWS Cent-OS. I've done this as I found that [boot2docker](https://github.com/boot2docker/boot2docker) was using a lot of memory and CPU on my laptop, and port forwarding is a pain. As I already have a free instance on Amazon AWS, I can use this. 

**(1) Get an [Amazon EC2](http://aws.amazon.com/ec2/) instance and install Cent-OS on it.**

I found it useful to put an alias into my `~/.ssh/config` with all the keys etc set-up so I can connect just using `ssh ec2`.

**(2) Install EPEl packages**

This is where Docker is. You'll need to know if you're 32 or 64 bit (almost certainly 64 bit):
	
	$ uname -i
	x86_64

And what version of Cent-OS you are running, so you know whether you need version 5 or 6 (most likely 6):

	$ cat /etc/redhat-release
	Red Hat Enterprise Linux Server release 6.5 (Santiago)
	
Then you can look at [this page](https://fedoraproject.org/wiki/EPEL) to find the right version of the RPM and install:

	$ sudo su
	$ wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
	rpm -Uvh epel-release-6*.rpm

**(3) Install Docker**

	$ yum -y install docker-io

**(4) Start Docker**

Now, you can [set-up docker as a daemon](http://docs.docker.io/installation/rhel/), but I want to use mine for development, I want to set-up port forwards. So I run a command to connect to the EC2 instance and start the daemon:

	ssh -t -L8080:localhost:8080 -L4243:localhost:4243 ec2 sudo docker -d -D -H tcp://127.0.0.1:4243

This command does a few things:

* Connects to your host and forwards ports 4243 (default Docker port) and port 8080 (where I run my apps). You may wish to forward other ports, e.g 3306 for MySQL
* Starts Docker in debug mode so you can look at what it is up to.
* Tells Docker to listen on port 4243.

When you're done, ctrl+c to shut it down.

**(5) Test**

You probably want to perform some basic smoke tests. You'll need to set-up an environment variable:

	export DOCKER_HOST=tcp://localhost:4243

Pull an image:

	docker pull centos
	
Run a simple command:

	docker run -t -i centos echo 'Hello world!'
	
Download from a repo:

	docker run -t -i centos yum -y install ping