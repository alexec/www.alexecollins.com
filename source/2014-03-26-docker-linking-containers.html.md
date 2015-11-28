---
title: Docker - Linking Containers
date: 2014-03-26 21:36 UTC
tags: docker
---
I've talked a bit about [creating a simple application container](/first-steps-with-docker), and a bit about [having  persistence by using "data only containers"](/docker-persistence). This tutorial is about how to create one container that can access a service on another.

Build this MySQL container:

	FROM centos
		
	RUN yum -y install mysql-server
	RUN touch /etc/sysconfig/network
	
	RUN service mysqld start &&  \
		sleep 5s && \
		mysql -e "GRANT ALL ON *.* to 'root'@'%'; FLUSH PRIVILEGES" 
	
	EXPOSE 3306
		
	CMD ["/usr/bin/mysqld_safe"]

We can start it as a **named container**:

	docker run -t -i --name mysql e17f4931c127

Build this online line container simple client:

	FROM centos
	
	RUN yum -y install mysql
	
	CMD ["bash"]

You can start this client linked to the MySQL container:

	docker run -t -i --link mysql:mysql a8f790f3cd57
	
When you link a container, various data is exposed into the environment:

	# env
	MYSQL_PORT_3306_TCP_PORT=3306
	MYSQL_PORT_3306_TCP=tcp://172.17.0.2:3306
	MYSQL_PORT_3306_TCP_PROTO=tcp
	MYSQL_NAME=/hungry_einstein/mysql
	MYSQL_PORT_3306_TCP_ADDR=172.17.0.2
	MYSQL_PORT=tcp://172.17.0.2:3306

The new container can now connect our MySQL database:

	# mysql -h $MYSQL_PORT_3306_TCP_ADDR
	mysql> 	
		
This isn't very helpful, it'd be better if it was mapped as a hostname! However, this is not a trivial thing to do, and Docker is missing this feature at the moment :(.

