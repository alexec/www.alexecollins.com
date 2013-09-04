---
title: "Tutorial: Integration Testing with Selenium - Part 1"
---
<h2>Overview</h2>

I've been using this for sometime and I've come across a few things that appear to make life easier. I thought I'd share this as a tutorial, so I'll walk you through these parts:

<ol>
<li>Setting up a web project using Maven, configuring Selenium to run as an integration test on a C.I.
<li>Look into good ways to model the pages in your site using "page objects" and other ways to create points of protected-variation.
<li>Use JPA and Hibernate to perform CRUD operations on a database, and have Maven perform integration tests on them, without any of the costly and often undocumented set-up that this sometimes entails.
</ol>

This post assumes you're comfortable with Java, Spring, Maven 2 and, of course, HTML. You'll also want Firefox installed on you computer. This tutorial is intended to be otherwise technology agnostic.

<h2>Creating a Webapp</h2>

Firstly we'll need a webapp to test. Create an project using the maven-webapp-archetype and call it "selenuim-tutorial".

To run integration tests (ITs) we're going to use the Cargo plugin. This starts and stops containers such as Jetty and Tomcat. You can use Cargo to start your site using Jetty (its default) in one command without any changes:

	mvn cargo:run

And check it in you browser at:

<a href="http://localhost:8080/selenuim-tutorial">http://localhost:8080/selenuim-tutorial</a>

You'll get a 404 without welcome file set-up, so add that to the web.xml file:

	<welcome-file-list>
		<welcome-file>/index.jsp</welcome-file>
	</welcome-file-list>

If you run cargo:run again you'll now see the "Hello World!" page that was created by Maven.

<h2>Configuring Cargo</h2>

We can set-up Cargo to start a Jetty container prior to running the tests, and then stop it afterwards. This will allow us to start our site, run the integration tests, and then stop it afterwards.

	<plugin>
		<groupId>org.codehaus.cargo</groupId>
		<artifactId>cargo-maven2-plugin</artifactId>
		<version>1.2.0</version>
		<executions>
			<execution>
				<id>start</id>
				<phase>pre-integration-test</phase>
				<goals>
					<goal>start</goal>
				</goals>
			</execution>
			<execution>
				<id>stop</id>
				<phase>post-integration-test</phase>
				<goals>
					<goal>stop</goal>
				</goals>
			</execution>
		</executions>
	</plugin>

You can test this work with:

	mvn verify

One thing to note at this point is that Cargo runs on port 8080. If you've already got a process listening on that port you might see an error similar to this:

	java.net.BindException: Address already in use

This might be because you're already running another container on this port. If you want to run this on a C.I. (which may itself run on port 8080), this is likely to be something you'll want to change. Add these lines to the plugin set-up:

	<configuration>
		<type>standalone</type>
		<configuration>
			<properties>
				<cargo.servlet.port>10001</cargo.servlet.port>
			</properties>
		</configuration>
	</configuration>

Now the app will be here:

<a href="http://localhost:10001/selenuim-tutorial/">http://localhost:10001/selenuim-tutorial/</a>

<h2>Setting-up Integration Test Phase</h2>

Next, we need to be able to run the integration tests. This requires the Maven failsafe plugin with appropriate goals added to your pom:

	<plugin>
		<groupId>org.apache.maven.plugins</groupId>
		<artifactId>maven-failsafe-plugin</artifactId>
		<version>2.12</version>
		<executions>
			<execution>
				<id>default</id>
				<goals>
					<goal>integration-test</goal>
					<goal>verify</goal>
				</goals>
			</execution>
		</executions>
	</plugin>

By default Failsafe expects tests to match the pattern "src/test/java/*/*IT.java".  Let's create a test to demonstrate this. Note that I haven't changed from Junit 3.8.1 yet. I'll explain to why later on.

Here's a basic, incomplete test:

	package tutorial;
	
	import junit.framework.TestCase;
	
	public class IndexPageIT extends TestCase {
	
		@Override
		protected void setUp() throws Exception {
			super.setUp();
		}
	
		@Override
		protected void tearDown() throws Exception {
			super.tearDown();
		}
		
		public void testWeSeeHelloWorld() {
			fail();
		}
	}

Test that works:
	
	mvn verify

You should see a single test failure. 

To test using Selenium you'll need to add a test-scoped dependency to pom.xml:

	<dependency>
		<groupId>org.seleniumhq.selenium</groupId>
		<artifactId>selenium-firefox-driver</artifactId>
		<version>2.19.0</version>
		<scope>test</scope>
	</dependency>

We can now make a couple of changes to our test:

	import org.openqa.selenium.WebDriver;
	import org.openqa.selenium.firefox.FirefoxDriver;
	
	…
	
		private URI siteBase;
		private WebDriver drv;
	
		@Override
		protected void setUp() throws Exception {
			super.setUp();
	
			siteBase = new URI("http://localhost:10001/selenuim-tutorial/");
			drv = new FirefoxDriver();
		}
	
	...
	
		public void testWeSeeHelloWorld() {
			drv.get(siteBase.toString());
			assertTrue(drv.getPageSource().contains("Hello World"));
		}

We'll remove these hard coded values later on.

Run it again:

	mvn verify

You shouldn't see any failures. What you will have is a lingering Firefox. It won't have closed. Run this test 100 times and you'll have 100 Firefoxs running. This will quickly become a problem. We can resolve this by adding this initialisation block to our test:

		{
			Runtime.getRuntime().addShutdownHook(new Thread() {
				@Override
				public void run() {
					drv.close();
				}
			});
		}

Naturally, if we create another test, we'll soon be violating DRY principles. We'll come to that in the next part, as well as looking at what happens when we require a database connection, and some other ways to make sure that your tests are simple to write and easy to maintain.

<a href="/content/tutorial-integration-testing-selenium-part-2">Continue to part 2</a>
