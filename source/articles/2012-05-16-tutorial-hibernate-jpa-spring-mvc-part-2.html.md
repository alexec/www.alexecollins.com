---
title: "Tutorial: Hibernate, JPA & Spring MVC - Part 2"
tags: hibernate,jpa,java,spring
---
<h2>Overview</h2>

<p>This tutorial will show you how to take a basic Hibernate/JPA app, convert it into a Spring MVC web project to be able to view the database in a web browser, and finally use Spring's @Transactional annotation to reduce boiler plate code.</p>

<p>This tutorial assumes you're familiar with Java and Maven, and that you've completed the <a href="/tutorial-hibernate-jpa-part-1">first part of this tutorial</a>. You'll also need to have downloaded and installed Tomcat.</p>

<p>You may wish to check out the code freshly from <a href="https://github.com/alexec/tutorial-hibernate-jpa/tree/part-1">Github</a>.</p>

<h2>Container Managed Data-Source</h2>

<p>There a number of key files that we'll need to amend or create to convert the code from part 1 into a web project. The first thing we'll need to do (assuming you've got Tomcat installed and have set CATALINA_HOME in your computer's environment) is to move the JDBC configuration to Tomcat's so that the data-source's are managed by Tomcat, rather than programatically, and can be accessed using JNDI.</p>

<p>To do this, add the following lines inside the GlobalNamingResources element of $CATALINA_HOME/conf/server.xml:</p>

~~~xml
	<Resource auth="Container" 
	    driverClassName="org.apache.derby.jdbc.EmbeddedDriver" 
	    maxActive="8" maxIdle="4" 
	    name="jdbc/tutorialDS" type="javax.sql.DataSource" 
	    url="jdbc:derby:tutorialDB;create=true" 
	    username="" password="" />
~~~

<p>A jar containing org.apache.derby.jdbc.EmbeddedDriver needs to be available to Tomcat. An quick way to get the jar is from your Maven local repository, e.g. ~/.m2/repository/org/apache/derby/derby/10.4.1.3/derby-10.4.1.3.jar. Copy that file into $CATALINA_HOME/lib and restart Tomcat to make sure there was no errors.</p>

<p>These changes will create a data source that deployed applications can access. In Tomcat 7 you can view the managed resources at <a href="http://localhost:8080/manager/text/resources">http://localhost:8080/manager/text/resources</a>; you should see something like:</p>

	OK - Listed global resources of all types
	jdbc/tutorialDS:org.apache.tomcat.dbcp.dbcp.BasicDataSource
	UserDatabase:org.apache.catalina.users.MemoryUserDatabase

<h2>Converting Into a Web Project</h2>

<p>Using the some project from part 1 we need to make the following changes:</p>

<p>We need to change the project to produce a web archive, so in the pom.xml add the following:</p>

~~~xml
<packaging>war</packaging>
~~~

<p>You'll want to add (as a convenience) a line inside the build section that creates a .war without the project version:</p>

~~~xml
<finalName>${project.artifactId}</finalName>
~~~

<p>We also need the servlet API libraries:</p>

~~~xml
<dependency>
	<groupId>javax.servlet</groupId>
	<artifactId>servlet-api</artifactId>
	<version>2.5</version>
	<scope>provided</scope>
</dependency>
~~~
<p>Note: the scope for this is "provided", as Tomcat already has a built in servlet library.</p>

<p>So that the data-source is available to the app, create src/main/webapp/META-INF/context.xml with the following lines:</p>

~~~xml
<Context>
	<ResourceLink global="jdbc/tutorialDS" name="jdbc/tutorialDS" type="javax.sql.DataSource"/>
</Context>

<p>This makes the data-source managed by Tomcat available to our app. We also need a stub for src/main/webapp/WEB-INF/web.xml:</p>

<web-app
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns="http://java.sun.com/xml/ns/javaee"
	xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd"
	version="2.5">
</web-app>
~~~

<p>Compile and deploy the app to Tomcat. You won't be able to see anything at this point, as there are no servlets or pages.</p>

<p>It's possible to get Maven to build and deploy to Maven for you, or you can run Tomcat within most IDEs. There's plenty of articles on this elsewhere, so I won't cover it here.</p>

<h2>Adding Spring MVC</h2>

<p>We're going to use Spring MVC for this, so we need some additional changes to support that:</p>

<p>Add the following dependency to your pom.xml:</p>

~~~xml
<dependency>
	<groupId>org.springframework</groupId>
	<artifactId>spring-webmvc</artifactId>
	<version>3.0.6.RELEASE</version>
</dependency>
~~~
<p>We want to tell Tomcat to use Spring to dispatch requests, so we need to add the following lines to our web.xml:</p>

~~~xml
<context-param>
	<param-name>contextConfigLocation</param-name>
	<param-value>/WEB-INF/mvc-dispatcher-servlet.xml</param-value>
</context-param>
	
<listener>
	<listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
</listener>
	
<servlet>
	<servlet-name>mvc-dispatcher</servlet-name>
	<servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
	<load-on-startup>1</load-on-startup>
</servlet>
	
<servlet-mapping>
	<servlet-name>mvc-dispatcher</servlet-name>
	<url-pattern>*.html</url-pattern>
</servlet-mapping>
~~~
<p>This will forward all requests for pages ending in ".html" to Spring and Spring will choose the appropriate controller to service each request. We also need to create an application context for Spring servlets, and this must live in src/main/webapp/WEB-INF/mvc-dispatcher-servlet.xml:</p>

~~~xml
<?xml version="1.0" encoding="UTF-8"?>	
<beans xmlns="http://www.springframework.org/schema/beans"
   	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   	xmlns:context="http://www.springframework.org/schema/context"
  	xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-2.5.xsd http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-2.5.xsd">
   	
   	<context:component-scan base-package="tutorial"/>
   	<context:annotation-config/>
   	
   	<bean class="org.springframework.web.servlet.view.InternalResourceViewResolver">
	   	<property name="prefix"><value>/WEB-INF/pages/</value></property>
		<property name="suffix"><value>.jsp</value></property>
	</bean>
</beans>
~~~

<p>This XML does two things:</p>

<ol>
<li>It tells Spring to scan classes in the package "tutorial" and beneath for classes annotated as beans.</li>
<li>How to convert the name of a view into it's resource. Essentially it says "take the name, prefix it with '/WEB-INF/pages' then suffix the result with '.jsp'".</li>
</ol>

<p>You might want to redeploy this to smoke test it.</p>

<p>To test this we'll need to display a page. The first page will be to display a list of all the users. We'll need two files; the first is the controller that services requests:</p>

~~~java
package tutorial;
	
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
	
@Controller
public class UsersController {
	
	@RequestMapping("/users")
	public String users(Model model) {
		return "users";
	}
}
~~~

<p>The second item is the page to display. This is based on the string returned by UsersController.users(), and using the rules for the resource resolver, we know this file must be WEB-INF/pages/users.jsp. Create stub of the page, something like:</p>

~~~html
<html>
	<body>
		<h1>Users</h1>
	</body>
</html>
~~~

<p>Finally, you can test this by redeploying to Tomcat and using a browser to view <a href="http://localhost:8080/tutorial-hibernate-jpa/users.html">http://localhost:8080/tutorial-hibernate-jpa/users.html</a>.</p>

<h2>Adding Spring ORM</h2>

<p>Spring contains support for injecting entity managers into beans, and this requires only a few lines of code to be added to your pom.xml and mvc-dispatcher-context.xml:</p>

~~~xml
<dependency>
	<groupId>org.springframework</groupId>
	<artifactId>spring-orm</artifactId>
	<version>3.0.6.RELEASE</version>
</dependency>
~~~

~~~xml
<jee:jndi-lookup id="tutorialDS" jndi-name="java:/comp/env/jdbc/tutorialDS" expected-type="javax.sql.DataSource"/>
	
<bean id="entityManagerFactory" class="org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean">
	<property name="dataSource" ref="tutorialDS"/>
</bean>
~~~

<p>The "jndi-lookup" element creates a bean from a JNDI resource, and this is used by the entity manager factory to create entity managers. Other JNDI objects can also be looked up in this fashion.</p>

<p>Note: you'll need to add the XML namespace and XSD to the root element: xmlns:jee="http://www.springframework.org/schema/jee."</p>

<p>Finally, we can add code to get the entity manager injected into our controller and get users from the database.</p>

~~~java
public class UsersController {
	
	@PersistenceContext
	private EntityManager entityManager;
	
	@RequestMapping("/users")
	public String users(Model model) {
	
		model.addAttribute("users", entityManager.createQuery("select u from User u").getResultList());
	
	        return "users";
	}
}
~~~

<p>This code uses the entity manager to get all the users and binds it to an attribute called "users" that will be visible to our JSPs.</p>

<p>We will want to show the users on the page. For this, I'll use JSTL; you can use another technology if you prefer, but I'll quickly give you the bits you'd need if not. Again, there's plenty of good tutorials on JSTL out there if you're not familiar. Firstly,  
add another dependency to you pom.xml:</p>

~~~xml
<dependency>
	<groupId>javax.servlet</groupId>
	<artifactId>jstl</artifactId>
	<version>1.2</version>
</dependency>
~~~

<p>And update users.html displays the users:</p>

~~~xml
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
body>
	<h1>Users</h1>
	<table>
	    <thead><tr><td>ID</td><td>Name</td></tr></thead>
	    <tbody>
	        <c:forEach var="user" items="${users}">
	        <tr><td>${user.id}</td><td>${user.name}</td></tr>
	        </c:forEach>
	    </tbody>
	</table>
</body>
</html>
~~~

<p>Finally, you can smoke test this in your browser.</p>

<h2>@Transactional</h2>

<p>The final piece of the puzzle is creating a user. To do this, we'll need a basic form, for example I've made pages/create-user.jsp:</p>

~~~html
<html>
<body>
	<h1>Create User</h1>
	<form method="post">
	Name: <input name="name"/>
	<input type="submit"/>
	</form>
</body>
</html>
~~~

<p>We need a controller to access this, so add this to UsersController:</p>

~~~java
@RequestMapping(value = "/create-user", method = RequestMethod.GET)
public String createUser(Model model) {
	return "create-user";
}
~~~

<p>Note: that this method only accepts GET requests. When we POST the form, we'll need another method. You can smoke test this by redeploying to Tomcat and browsing to <a href="http://localhost:8080/tutorial-hibernate-jpa/create-user.html">http://localhost:8080/tutorial-hibernate-jpa/create-user.html</a>. You'll note that submitting the page results in a HTTP 405 error. We can service POST requests with the following (overloaded) method:</p>

~~~java
@RequestMapping(value = "/create-user", method = RequestMethod.POST)
@Transactional
public String createUser(Model model, String name) {
	        
	User user = new User();
	user.setName(name);
	        
	entityManager.persist(user);
	        
	return "redirect:/users.html";
}
~~~

<p>We've used the @Transactional annotation here. When we do this, Spring will create a proxy object for our bean and manage the transaction for us, beginning, committing and rolling back when errors occur. This is much less code (one line vs about a dozen) and safer (less chance for a typographical error) than opening and closing the transaction ourself. You can see an example of the code for the verbose version in <a href="/tutorial-hibernate-jpa-part-1">this post</a>. We need to tell Spring to support this by adding the following lines to our Spring context: telling it to use annotation based transactions, and what bean should manage the transactions:</p>

~~~xml
<tx:annotation-driven/>
	
<bean id="transactionManager" class="org.springframework.orm.jpa.JpaTransactionManager">
	<property name="entityManagerFactory" ref="entityManagerFactory" />
</bean>
~~~

<p>Note: you'll need to add the correct schema the the document too:</p>

	xmlns:tx="http://www.springframework.org/schema/tx"
	...
	http://www.springframework.org/schema/tx http://www.springframework.org/schema/tx/spring-tx-2.5.xsd
~~~

<p>You can test this by going to the page and submitting a new user. You'll be redirected to the users page afterwards where you should be able to see your new user.</p>

<h2>Conclusion</h2>

<p>In this example, there are more lines of XML than Java, but most of the XML is one-off set-up, and you'll find that as your app gets larger, the ratio drops. You can use Spring to support JPA entities, making a migration to/from JEE easier.</p>

<p>I've only covered the "C" and "R" parts of CRUD here, you should have enough information here to be able to try the rest yourself.</p>

<p>The code for this is on <a href="https://github.com/alexec/tutorial-hibernate-jpa/tree/part-2">Github</a>.</p>
