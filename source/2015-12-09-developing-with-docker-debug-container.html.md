---
title: Developing With Docker - The Debug Container
date: 2015-11-28 01:00 UTC
tags: docker, developing-with-docker
---
One technique that's proven to be useful over and over again when working with Docker is a *Debug Container*. The debug container isn't a proper application, nor is it a one off job. It's simply used for debugging problems. 

Lets have a look at a common problem.

### Problem

You want to connect to get a URL from an application listening on a port, but no connected containers or hosts have curl installed.

### Solution

Create a *Debug Container* and link it to the problem container. 

I'm going to assume the container running the app is called `foo` here, but change it to whatever you want. Firstly, create the following `Dockerfile`:

    FROM centos:centos7

    RUN yum install -y curl

    CMD ["/bin/sleep", "9999"]

Build and tag the image:

    docker build -t debug:1 .
    
Now we can test it out to run a one off command:

    docker run -ti --rm --link foo:foo debug:1 curl -v http://foo

### Discussion

You can use the image in a number of ways. You can start it up in the background, name it, and then use `docker exec`:

    docker run --rm --link foo:foo --name debug debug:1 
    docker exec debug curl http://foo
    
You can run `bash` in the container:

    docker run --rm -ti --link foo:foo debug:1 bash
    $ curl -v http://foo
    $ exit

Or use` docker exec`:

    docker run --rm --link foo:foo --name debug debug:1 
    docker exec -ti debug bash
    $ curl...

When you're pairing, we call this "docker bash" :)

I hope you've gotten the outline. Here are some thing to consider:

* I've used CentOS as my base image, naturally you can use whatever you're comfortable with.
* You probably want to install more packages. For example, I find `telnet` and `nslookup` useful.
* Creating the debug container can be done just when you need it, but you'll save time by doing it up front.
* The `sleep` command keeps the conntainer running, but doing nothing.
* The `--rm` option to `docker run` makes sure the container is removed when no longer in use, this prevent resource leakage.
* This can also be used in a cluster. As the container is within the cluster's subnet, it'll be subject to all the networking rules and restrictions a normal container would be.

