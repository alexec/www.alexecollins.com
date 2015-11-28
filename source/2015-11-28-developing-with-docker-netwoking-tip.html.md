---
title: Developing With A Node Gateway
date: 2015-11-28 01:00 UTC
tags: docker
---
I've been working with Docker a lot more recently. I've started to find some issue with it when working with several containers. One solution to the problem of accessing containers who exposing the same port is what I call a **dev gateway container**.

As I work on OS-X, these tips will be OS-X + Docker Machine based.

I'd like to connect to Docker containers using their hostname and port from my host PC. This means I do not need to change any configuration. Normal port expose does not work, if I have more than one service running on the same port. 

We can use the fact that HTTP request have `Host` header which indicates the name of the host the request was sent to.

We can get around this by:

1. Changing the dev machines `/etc/hosts` to sent HTTP requests for our services to Docker machine.
2. Running a gateway container on the Docker machine that inspects the `Host` HTTP header, and then proxies the request to the correct container.

## Example

Lets have two containers: "foo" and "bar". Both are listening on port 80. On my computer, if I open  <http://foo> I should see the side on the `foo` container. 

In a `foo` directory, create a `Dockerfile`:

~~~
FROM nginx:1.9.7

ADD index.html /usr/share/nginx/html/
~~~

And an `index.html`:

~~~
Hello Foo!
~~~

Repeat this for a directory named `bar`.

Finally, create this `docker-compose.yml` file:

~~~yml
foo:
  build: foo
  container_name: foo
bar:
  build: bar
  container_name: bar
~~~

If you run `docker-compose up` it will create two Nginx containers that have different HTML pages. 


We want to have all requests to `foo` and `bar` sent to the Docker machine. I'm using Docker Machine on OS-X, and by default it runs on `192.168.99.100`, so I can add these lines to `/etc/hosts`:

~~~
192.168.99.100 foo
192.168.99.100 bar
~~~

But unfortunately, I cannot expose more than one container on port 80. I'm going to use a third container called `gw` (for gateway) to sit in front of both my services, and proxy requests. This has the following `Dockerfile`:

~~~
FROM nginx:1.9.7

ADD default.conf /etc/nginx/conf.d/
~~~

The `default.conf` is:

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

This configuration will proxy any request to which has a HTTP header of `Host: foo` to `foo`, and likewise for `bar`.

Finally, create this `docker-compose.yml` file:

~~~yml
foo:
  build: foo
  container_name: foo
bar:
  build: bar
  container_name: bar
gw:
  build: gw
  container_name: gw
  links:
  - foo
  - bar
  ports:
  - 80:80
~~~

Finally, do `docker-compose up` to get them running.

If you request either URL from your host machine, the request will go to the correct container. 
