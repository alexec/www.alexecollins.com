---
title: Developing With Docker - Debugging Containerized Micro-services
date: 2016-03-03 21:00 UTC
tags: docker, developing-with-docker
---
This is my third post in a series on [developing with Docker](/tags/developing-with-docker/). If you're developing micro-services, there's a very good chance you are if you're using Docker, then you probably have a number of them communicating over TCP (or maybe UDP). This technique will show you how to debug those containers, especially useful when your logs simply don't give you enough information alone.

You'll need experience of Docker and be comfortable in a terminal.

### Problem

You're trying to debug an issue that is inter-container, and you want to see traffic over the network.

### Solution

Use the `tcpdump` tool to examine the network traffic.

To demonstrate this, we're going to start a simple Nginx container to fill the role of one of the applications:

    docker run --rm -ti -p 80:80 nginx

You can test this is working by using `curl` to fill the role of another application (change the IP address to that your Docker host):

    curl http://192.168.99.100

You should see the welcome page, and the Nginx container should log something similar the following:

    192.168.99.1 - - [03/Mar/2016:21:41:08 +0000] "GET / HTTP/1.1" 200 612 "-" "curl/7.43.0" "-"

Now, image that rather than `curl` on your local machine, it's actually an application you cannot modify making the HTTP request. You would not normally be able to see any of the exchange.

Lets see how to see it using `tcpdump`.

On either your Docker host (or the machine making the request) you can run the following command to get a list of network interfaces:

    ifconfig

Ignore any network interfaces that do not have an IP address. If the command lists `docker0` use that, otherwise look for `en0` or `eth0`. If you're using a Docker virtual machine (e.g. Boot2Docker) look for one that matches `vboxnet*` (in my case it is `vboxnet3`).

    tcpdump -i vboxnet3 -s 0 -l -vvv

Now request the page again (e.g. in a shell):

    curl http://192.168.99.100

You should see details of the request printed in the terminal running `tcpdump`:

    22:17:23.150782 IP (tos 0x0, ttl 63, id 13829, offset 0, flags [DF], proto TCP (6), length 290)
        192.168.99.100.http > 192.168.99.1.56705: Flags [P.], cksum 0xeef0 (correct), seq 1:239, ack 79, win 227, options [nop,nop,TS val 1741227 ecr 82684063], length 238: HTTP, length: 238
    	HTTP/1.1 200 OK
    	Server: nginx/1.9.11
    	Date: Thu, 03 Mar 2016 22:12:05 GMT
    	Content-Type: text/html
    	Content-Length: 612
    	Last-Modified: Tue, 09 Feb 2016 18:01:51 GMT
    	Connection: keep-alive
    	ETag: "56ba298f-264"
    	Accept-Ranges: bytes

### Discussion

The `tcpdump` command is a low-level debugging command for Linux systems. If you run OS-X, you'll find that the syntax of the command is slightly different to Linux, but the principles remain the same.

If you have a number of containers running on a single host, you can add a filter to reduce the amount of output:

    tcpdump -i vboxnet3 -s 0 -l -vvv 'tcp port 80'

Or, by host if you have a specific IP address (this works well with Kubernetes):

    tcpdump -i vboxnet3 -s 0 -l -vvv 'host 10.254.0.8'

It take a few hours to get comfortable with `tcpdump`, but persevere. There are a couple of reasons that I like using this tool so much:

* You can get a great deal of debugging information out of a container, far more than logs alone.
* You don't need to modify the container, or often the host, to get this information.
* It works on the desktop, in your container cluster, or any remote host.
