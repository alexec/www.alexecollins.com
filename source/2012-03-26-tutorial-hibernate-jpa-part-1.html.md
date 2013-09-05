---
title: "Tutorial: Hibernate, JPA - Part 1"
---
<h1>Overview</h1>

This is the first part of tutorial about using Hibernate and JPA. This part is an introduction to to JPA and Hibernate. The second part will look at putting together a Spring MVC application using Spring ORM to reduce the amount of code necessary to create a CRUD application.

To complete this you'll want to be familiar with Maven, JUnit, SQL and relational databases.

<h2>Dependencies</h2>

Firstly we'll need a couple of basic dependencies. Essentially there are three layers:

<ol>
<li>The lowest layer is the JDBC drivers used by Hibernate to connect to the database. I'm going to use Derby, a simple embedded database. There's no server to install or configure so it's easier to set-up that even MySQL or PostgreSQL; it's not suitable for production.</li>
<li>The middle layer is the Hibernate libraries. I'm going to use version 3.5.6. This works with Java 1.5, 4.x does not.</li>
<li>The JPA libraries.</li>
</ol>

Additionally we'll want JUnit for creating tests and Tomcat so we can using it's JNDI naming for tests. JNDI is a preferable system to including the server details in a properties file for reasons we'll come to.

~~~xml
	<dependencies>
	        <dependency>
	            <groupId>org.apache.derby</groupId>
	            <artifactId>derby</artifactId>
	            <version>10.4.1.3</version>
	        </dependency>
	        <dependency>
	            <groupId>org.hibernate</groupId>
	            <artifactId>hibernate-entitymanager</artifactId>
	            <version>3.6.9.Final</version>
	        </dependency>
	        <dependency>
	            <groupId>org.hibernate.javax.persistence</groupId>
	            <artifactId>hibernate-jpa-2.0-api</artifactId>
	            <version>1.0.0.Final</version>
	        </dependency>
	        <dependency>
	            <groupId>junit</groupId>
	            <artifactId>junit</artifactId>
	            <version>4.10</version>
	            <scope>test</scope>
	        </dependency>
	        <dependency>
	            <groupId>org.apache.tomcat</groupId>
	            <artifactId>catalina</artifactId>
	            <version>6.0.18</version>
	            <scope>test</scope>
	        </dependency>
	    </dependencies>
~~~

<h2>Configuration</h2>

The key config file for JPA is persistence.xml. This lives in the META-INF directory. It details what the persistence driver to use and what JNDI data source to connect to. Additional properties can also be specified, in this case we'll include some Hibernate properties. 

I've added some comments on the additional properties so you know what they are for. You can configure the data source directly, but using JNDI means we can easily deploy the code in a container, as a standalone or to run unit tests, with minimal code changes.

~~~xml
	<?xml version="1.0" encoding="UTF-8"?>
	<persistence xmlns="http://java.sun.com/xml/ns/persistence"
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xsi:schemaLocation="http://java.sun.com/xml/ns/persistence http://java.sun.com/xml/ns/persistence/persistence_1_0.xsd"
		version="1.0">
	
		<persistence-unit name="tutorialPU" transaction-type="RESOURCE_LOCAL">
			<provider>org.hibernate.ejb.HibernatePersistence</provider>
			<!-- the JNDI data source -->
			<non-jta-data-source>java:comp/env/jdbc/tutorialDS</non-jta-data-source>
			<properties>
				<!-- if this is true, hibernate will print (to stdout) the SQL it executes, 
					so you can check it to ensure it's not doing anything crazy -->
				<property name="hibernate.show_sql" value="true" />
				<property name="hibernate.format_sql" value="true" />
				<!-- since most database servers have slightly different versions of the 
					SQL, Hibernate needs you to choose a dialect so it knows the subtleties of 
					talking to that server -->
				<property name="hibernate.dialect" value="org.hibernate.dialect.DerbyDialect" />
				<!-- this tell Hibernate to update the DDL when it starts, very useful 
					for development, dangerous in production -->
				<property name="hibernate.hbm2ddl.auto" value="update" />
			</properties>
		</persistence-unit>
	</persistence>
~~~

<h2>Entities</h2>

JPA talks in terms of entities rather than database records. An entity is an instance of a class maps to a single record in a table (classes map to tables). The entities fields (which should use the JavaBean naming convention) are mapped to columns.  

Annotations can be used to add extra information to the class. They mark the class as being an entity, and allow you to specify meta information about the table and columns, such as names, sizes, and constraints.

In our case we're going to start with the simplest entity possible.

~~~java
	package tutorial;
	
	import javax.persistence.*;
	import java.util.HashSet;
	import java.util.Set;
	
	@Entity
	@Table(name = "usr") // @Table is optional, but "user" is a keyword in many SQL variants 
	public class User {
	    @Id // @Id indicates that this it a unique primary key
	    @GeneratedValue // @GeneratedValue indicates that value is automatically generated by the server
	    private Long id;
	
	    @Column(length = 32, unique = true)
	    // the optional @Column allows us makes sure that the name is limited to a suitable size and is unique
	    private String name;
	
	    // note that no setter for ID is provided, Hibernate will generate the ID for us
	
	    public long getId() {
	        return id;
	    }
	
	    public void setName(String name) {
	        this.name = name;
	    }
	
	    public String getName() {
	        return name;
	    }
	}
~~~

JPA can use the meta information to create the DDL when it starts up. This is helpful for development as it allows you to quickly get up and running without delving into the SQL needed to create tables. Want to add a column? Just add the column, compile and run. Unfortunately, what you gain in convenience is also an increase in risk (e.g. what does the database server do when a table has millions of records and you add a new column?) and loss of control.

There's a compromise, once the entities have been created by Hibernate, you can export the DDL and change Hibernate's config to stop it updating the DDL. 

<h2>Test Case</h2>

There are only two pieces, first we'll create an abstract test case as a root for all our tests. This will register a data source with JNDI, and we will extend it with other tests so that they access to the database.

~~~java
	package tutorial;
	
	import org.apache.derby.jdbc.EmbeddedDataSource;
	import org.apache.naming.java.javaURLContextFactory;
	import org.junit.AfterClass;
	import org.junit.BeforeClass;
	
	import javax.naming.Context;
	import javax.naming.InitialContext;
	
	public abstract class AbstractTest {
	
		@BeforeClass
		public static void setUpClass() throws Exception {
			System.setProperty(Context.INITIAL_CONTEXT_FACTORY, javaURLContextFactory.class.getName());
			System.setProperty(Context.URL_PKG_PREFIXES, "org.apache.naming");
			InitialContext ic = new InitialContext();
	
			ic.createSubcontext("java:");
			ic.createSubcontext("java:comp");
			ic.createSubcontext("java:comp/env");
			ic.createSubcontext("java:comp/env/jdbc");
	
			EmbeddedDataSource ds = new EmbeddedDataSource();
			ds.setDatabaseName("tutorialDB");
			// tell Derby to create the database if it does not already exist
			ds.setCreateDatabase("create");
	
			ic.bind("java:comp/env/jdbc/tutorialDS", ds);
		}
	
		@AfterClass
		public static void tearDownClass() throws Exception {
	
			InitialContext ic = new InitialContext();
	
			ic.unbind("java:comp/env/jdbc/tutorialDS");
		}
	}
~~~

The final piece is the test case. The entity manger provide access to the data. The persist operation (which will result in a single insert in this case) must be performed in a transaction. In fact Hibernate will not do any work until the commit. You can see this by adding a Thread.sleep immediately prior to the commit. 

~~~java
	@Test
	    public void testNewUser() {
	
	        EntityManager entityManager = Persistence.createEntityManagerFactory("tutorialPU").createEntityManager();
	
	        entityManager.getTransaction().begin();
	
	        User user = new User();
	
	        user.setName(Long.toString(new Date().getTime()));
	
	        entityManager.persist(user);
	
	        entityManager.getTransaction().commit();
	
	        // see that the ID of the user was set by Hibernate
	        System.out.println("user=" + user + ", user.id=" + user.getId());
	
	        User foundUser = entityManager.find(User.class, user.getId());
	
	        // note that foundUser is the same instance as user and is a concrete class (not a proxy)
	        System.out.println("foundUser=" + foundUser);
	
	        assertEquals(user.getName(), foundUser.getName());
	
	        entityManager.close();
	    }
~~~

<h2>Exception Handling</h2>

The need for a begin and commit is verbose. Additionally, the last example is incomplete, as it misses any rollback if an exception occurs. 

Exception handling is boiler plate code. Like it's JDBC equivalent, it's not pretty. Here's a example:

~~~java
	 @Test(expected = Exception.class)
	    public void testNewUserWithTxn() throws Exception {
	
	        EntityManager entityManager = Persistence.createEntityManagerFactory("tutorialPU").createEntityManager();
	
	        entityManager.getTransaction().begin();
	        try {
	            User user = new User();
	
	            user.setName(Long.toString(new Date().getTime()));
	
	            entityManager.persist(user);
	
	            if (true) {
	                throw new Exception();
	            }
	
	            entityManager.getTransaction().commit();
	        } catch (Exception e) {
	            entityManager.getTransaction().rollback();
	            throw e;
	        }
	
	        entityManager.close();
	    }
~~~

I'll leave the exception management out for the moment as there are better ways to do it. Later we'll look at how JSR-330's @Inject and Spring Data's @Transactional can reduce the boiler plate.

<h2>Entity Relations</h2>

Since we're using relational databases, we'll almost certainly want to create a relation between entities. We'll create a role entity and have a many to many relationship between user and role. To create the role entity, just copy the User entity, name it Role and remove the @Table line. We don't need to create a UserRole entity. But we will want to add and remove roles from the user.

Add the following field and method to the user table:

~~~java
	    @ManyToMany
	    private Set<Role> roles = new HashSet<Role>();
	
	    public boolean addRole(Role role) {
	        return roles.add(role);
	    }
	
	    public Set<Role> getRoles() {
	        return roles;
	    }
~~~

The @ManyToMany annotation tells JPA that it's a many-to-many relation. We can test this with a new test case. This test creates a user and role in one transaction and then updates the user in the second using merge. Merges are used to update an entity in the database.

~~~java
	  @Test
	    public void testNewUserAndAddRole() {
	
	        EntityManager entityManager = Persistence.createEntityManagerFactory("tutorialPU").createEntityManager();
	
	        entityManager.getTransaction().begin();
	
	        User user = new User();
	
	        user.setName(Long.toString(new Date().getTime()));
	
	        Role role = new Role();
	
	        role.setName(Long.toString(new Date().getTime()));
	
	        entityManager.persist(user);
	        entityManager.persist(role);
	
	        entityManager.getTransaction().commit();
	
	
	        assertEquals(0, user.getRoles().size());
	
	
	        entityManager.getTransaction().begin();
	
	        user.addRole(role);
	
	        entityManager.merge(user);
	
	        entityManager.getTransaction().commit();
	
	
	        assertEquals(1, user.getRoles().size());
	
	
	        entityManager.close();
	    }
~~~

<h2>Queries</h2>

JPA allows you to use a query language with a strong similarity to SQL called JPQL. Queries can be written directly, but named queries are easier to control, to maintain and exhibit better performance as Hibernate can prepare the statement. They are specified using the @NamedQuery annotation. Add this line to the User class after the @Table annotation:

~~~java
	@NamedQuery(name="User.findByName", query = "select u from User u where u.name = :name")

You can test this as follows:

		@Test
		public void testFindUser() throws Exception {
	
			EntityManager entityManager = Persistence.createEntityManagerFactory("tutorialPU").createEntityManager();
	
			entityManager.getTransaction().begin();
	
			User user = new User();
	
			String name = Long.toString(new Date().getTime());
	
			user.setName(name);
	
			Role role = new Role();
	
			role.setName(name);
	
			user.addRole(role);
	
			entityManager.persist(role);
			entityManager.persist(user);
	
			entityManager.getTransaction().commit();
	
			entityManager.close();
	
			entityManager = Persistence.createEntityManagerFactory("tutorialPU").createEntityManager();
	
			User foundUser = entityManager.createNamedQuery("User.findByName", User.class).setParameter("name", name)
					.getSingleResult();
	
			System.out.println(foundUser);
	
			assertEquals(name, foundUser.getName());
	
			assertEquals(1, foundUser.getRoles().size());
	
			System.out.println(foundUser.getRoles().getClass());
	
			entityManager.close();
		}
~~~

In this example I've closed and reopened the entity manager. This forces Hibernate to request the user from the database. Notice anything interesting about the output? The SQL for getting the roles appears after the toString of the found user. Hibernate creates a proxy object for the roles (in this case a org.hibernate.collection.PersistentSet), and only populates it when you first access the object. This can result in counter-intuitive behaviour and has its own set of pitfalls.

Try this variation of the above test where we close the entity manager before we first query the roles:

~~~java
		@Test(expected = LazyInitializationException.class)
		public void testFindUser1() throws Exception {
	
			EntityManager entityManager = Persistence.createEntityManagerFactory("tutorialPU").createEntityManager();
	
			entityManager.getTransaction().begin();
	
			User user = new User();
	
			String name = Long.toString(new Date().getTime());
	
			user.setName(name);
	
			Role role = new Role();
	
			role.setName(name);
	
			user.addRole(role);
	
			entityManager.persist(role);
			entityManager.persist(user);
	
			entityManager.getTransaction().commit();
	
			entityManager.close();
	
			entityManager = Persistence.createEntityManagerFactory("tutorialPU").createEntityManager();
	
			User foundUser = entityManager.createNamedQuery("User.findByName", User.class).setParameter("name", name)
					.getSingleResult();
	
			entityManager.close();
	
			assertEquals(1, foundUser.getRoles().size());
		}
~~~

The LazyInitializationException will be thrown on the getRoles() call. This is not a bug. Once the entity manager is closed, any entity can become unusable.

<h2>End</h2>

This is the basics to get up and running with Hibernate JPA. In the next part of this tutorial, I'll discuss validation, and look at some other details in more depth.

This tutorial is <A href="https://github.com/alexec/tutorial-hibernate-jpa/tree/part-1">on Github</a>.

You might want to do <a href="/content/tutorial-hibernate-jpa-spring-mvc-part-2">Part 2</a>.
