---
title: Developing With Docker - Using A Proxy Container To Make Development Easier
date: 2015-11-28 01:00 UTC
tags: docker, developing-with-docker
---
I've been working with Docker a lot recently. I've started to find issuess when working with several containers. In this post I will show you a solution to the problem of developing containers that expose the same port, with what I call a **proxy container**.

As I work on OS-X, these tips will be OS-X + Docker Machine, and Docker Compose based.

You can find the example on [Github](https://github.com/alexec/docker-proxy-container-example).

### Problem

So -- here's the problem:

* You're running a cluster of containers for local development (e.g. using Docker Compose).
* You'd like to connect to your Docker containers using hostname and port from your host PC. This will mean that you do not need to change any configuration when developing or testing apps to point to your local machine, or to your Docker machine, it should just work.
* This must work even if you have two containers that are listening on the same port.

### Solution

Have a single public container in your cluster that accepts all HTTP requests, and proxies them to correct container.

HTTP requests have a header named `Host` that contains the name of the host the request was sent to. We can use this in our proxy.

The steps will be:

1. Changing the dev machine's `/etc/hosts` to send HTTP requests for our services to our Docker machine.
2. Create a proxy container on our Docker machine that inspects the `Host` HTTP header, and then proxies the request to the correct container.

To demostrate this, lets have two containers: "foo" and "bar". Both are listening on port 80 and display a simple static web page. If I open <http://foo> in a browser, I should see the HTML page served by the `foo` container.

In a `foo` directory, create a `Dockerfile`:

~~~Dockerfile
FROM nginx:1.9.7

ADD index.html /usr/share/nginx/html/
~~~

And an `index.html`:

~~~html
<html>Hello Foo!</html>
~~~

Repeat this for a directory named `bar`, but change the `index.html` to have different HTML (e.g. "Hello Bar!").

Create this `docker-compose.yml` file in your project root:

~~~yml
foo:
  build: foo
  container_name: foo
bar:
  build: bar
  container_name: bar
~~~

If you run `docker-compose up` it will create two Nginx containers that serve two different HTML pages.

We want to have all requests to `foo` and `bar` sent to our Docker machine. Docker Machine on OS-X by default has the IP `192.168.99.100`, so add these lines to your `/etc/hosts` file so that requests to those hosts get forwarded:

~~~
192.168.99.100 foo
192.168.99.100 bar
~~~

You cannot expose more than one container per machine on port 80. But, you can make a third container called `proxy` to sit in front of both of the containers, and proxy requests. In a new directory name `proxy`, create the following `Dockerfile`:

~~~Dockerfile
FROM nginx:1.9.7

ADD default.conf /etc/nginx/conf.d/
~~~

The `default.conf` is an Nginx configuration file. This file forwards requests to containers based on the host name:

~~~
upstream foo {
    server foo;
}
upstream bar {
    server bar;
}
server {
    listen       80;
    server_name  localhost;

    location / {
       proxy_pass http://$host;
    }
}
~~~

This configuration will proxy any request to which has a HTTP header of `Host: foo` to `foo`, and likewise `Host: bar` to `bar`.

Update the `docker-compose.yml` file to add the proxy:

~~~yml
foo:
  build: foo
  container_name: foo
bar:
  build: bar
  container_name: bar
proxy:
  build: proxy
  container_name: proxy
  links:
  - foo
  - bar
  ports:
  - 80:80
~~~

Finally, do `docker-compose up` to get them up and running.

If you request either URL from your host machine, the request will go to the correct container.

### Discussion

This technique is a good starting point. It's aimed at making development easier, but putting a proxy container in front of a cluster of containers can also be used in production, so that you do not need to expose containers directly.

The above `default.conf` is not secure enough for production. I've used Nginx, as I'm familiar with it, but you could also you HA Proxy for this task.

In fact, you can do this automatically using [Jason Wilder's Nginx proxy](http://jasonwilder.com/blog/2014/03/25/automated-nginx-reverse-proxy-for-docker/), and this is well worthwhile looking at for complex projects.

This is the first article in a series on [developing with Docker](/tags/developing-with-docker) I'm planning on writing:

1. The Proxy Container Pattern
2. The Debug Container
3. Debugging using `docker exec`
4. Routing messages out of a cluster to your local machine.
