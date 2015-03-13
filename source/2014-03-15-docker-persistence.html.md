---
title: Docker - Persistence
date: 2014-03-15 10:02 UTC
tags: docker
---
I've already [written about Docker](/content/first-steps-with-docker/). One big thing is that when you run a Docker image, the data for the last run is not persisted. If you're creating a database container, you probably want this data kept around. There is a pattern for this, generally called the **data only container**.

Consider the following MySQL `Dockerfile`:

~~~
FROM centos

VOLUME /var/lib/mysql

RUN yum -y install mysql-server
RUN touch /etc/sysconfig/network

EXPOSE 3306
~~~

When you run this, you can create some test data (I've removed some of the output for brevity):

~~~
$ docker build .
...
Successfully built b962491b87db
$ docker run -i -t b962491b87db bash
bash-4.1# service mysqld start
bash-4.1# mysql -u root
mysql> connect test;
mysql> create table a(a int);
Query OK, 0 rows affected (0.01 sec)
~~~

Now exit the container (Ctrl+C), and lets check our data:

~~~
docker run -i -t b962491b87db bash
bash-4.1# service mysqld start
bash-4.1# mysql -u root
mysql> connect test;
mysql> select * from a;
ERROR 1146 (42S02): Table 'test.a' doesn't exist
~~~

Whoa! Where's my table gone? This shouldn't be a surprise for anyone who knows Docker well, but it caught me out, as I was expecting containers to act more like VMs. But I was confused, both images and containers have homogenic hexadecimal IDs, and `run` starts a new container from an image, where as `start` starts a container.  Confusing eh? I started the **image** not the **container**, so it was fresh. But what if I wanted to share the `Dockerfile` with someone else? There'd be no data on it. I fact, this is something I'd want. Rather than give them a container full of old test data, I'd want it to empty. That way, if I want to put it into production, there's no danger of test data staying on there. But how can I keep my test data around, well, we can use the aforementioned **data only container**. Create this `Dockerfile`:

~~~
FROM centos

VOLUME /var/lib/mysql

CMD ["true"]
~~~

Now build and run.

~~~
$ docker build .
...
Successfully built 5f2bca5b686e
$ docker run -name data 5f2bca5b686e
~~~

You'll notice that I've named the container for easy reference. You'll also notice that it exited without doing anything. That's because we don't need it to even be running for this to work.

Now, lets try again (note the `-volumes-from` argument):

~~~
$ docker run -i -t -volumes-from data b962491b87db bash
bash-4.1# service mysqld start 
bash-4.1# mysql -u root
mysql> connect test;
mysql> create table a(a int);
Query OK, 0 rows affected (0.01 sec)
~~~

Now exit, and do this:

~~~
$ docker run -i -t -volumes-from data b962491b87db bash
bash-4.1# service mysqld start
bash-4.1# mysql -u root
mysql> connect test;
mysql> select * from a;
Empty set (0.00 sec)
~~~

Great stuff! My data is persisted! Watch out for confusing container IDs and image IDs.