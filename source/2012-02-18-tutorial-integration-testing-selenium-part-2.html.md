---
title: "Tutorial: Integration Testing with Selenium - Part 2"
---
<h2>Overview</h2>

In the <a href="/content/tutorial-integration-testing-selenium-part-1">previous part of this tutorial</a> I covered the basics of setting up Maven with a small web project running integration tests. This post will cover <a href="http://en.wikipedia.org/wiki/GRASP_(object-oriented_design)#Protected_Variations">protected variation</a> using page objects and Spring context.

You'll will need to complete the <a href="/content/tutorial-integration-testing-selenium-part-1">previous post</a> before starting this one.

<h2>Spring Context</h2>

In the previous example, the URI for the app, and the driver used were both hard coded. Assuming you're familiar with Spring context, this is a pretty straight forward to change these. Firstly we'll add the correct dependencies:

	<dependency>
		<groupId>org.springframework</groupId>
		<artifactId>spring-context</artifactId>
		<version>3.1.1.RELEASE</version>
		<scope>test</scope>
	</dependency>

This will allow us to use and application context to inject dependencies. But we'll also need the correct Junit runner to test this, which can be found in the spring-test package:

	<dependency>
		<groupId>org.springframework</groupId>
		<artifactId>spring-test</artifactId>
		<version>3.1.1.RELEASE</version>
		<scope>test</scope>
	</dependency>

We can now update our test to use this. Firstly we'll need to create src/test/resources/applicationContext-test.xml

	<?xml version="1.0" encoding="UTF-8"?>
	<beans xmlns="http://www.springframework.org/schema/beans"
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-2.5.xsd">
	
		<bean id="siteBase" class="java.net.URI">
			<constructor-arg value="http://localhost:10001/selenuim-tutorial/" />
		</bean>
	
		<bean id="drv" class="org.openqa.selenium.firefox.FirefoxDriver" destroy-method="quit"/>
	</beans>

Spring will clear up the browser when it finishes, so we can remove the shutdown hook from AbstractIT. This is more robust than having the test case do this.

The spring-test doesn't work with JUnit 3, it needs at least JUnit 4.5. Lets update to version 4.10 in our pom.xml:

	<dependency>
		<groupId>junit</groupId>
		<artifactId>junit</artifactId>
		<version>4.10</version>
		<scope>test</scope>
	</dependency>

Finally, we need to update our test to work with both Spring and JUnit 4.x:

	package tutorial;
	
	import static org.junit.Assert.assertTrue;
	
	import java.net.URI;
	
	import org.junit.Test;
	import org.junit.runner.RunWith;
	import org.openqa.selenium.WebDriver;
	import org.springframework.beans.factory.annotation.Autowired;
	import org.springframework.test.context.ContextConfiguration;
	import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
	
	@RunWith(SpringJUnit4ClassRunner.class)
	@ContextConfiguration(locations = { "/applicationContext-test.xml" })
	public class IndexPageIT {
	
		@Autowired
		private URI siteBase;
	
		@Autowired
		private WebDriver drv;
	
		@Test
		public void testWeSeeHelloWorld() {
	...

These changes moved the configuration from hard coded values into XML config. We can now change the location we are testing, e.g. to a different host, and change the web driver we're using, which is left as an exercise for the user.

A quick note on browsers. I've found that after a browser update, tests often start failing. There appears to be two solutions to this:

<ul>
<li>Upgrade to the latest version of the web driver.</li>
<li>Don't upgrade the browser.</li>
</ul>

I suspect the first option is the best in most cases, for security reasons

<h2>Abstract IT</h2>

Currently, you'll need to duplicate all the code for IoC. A simple refactoring can sort this out. We'll create a super-class for all tests, and pull-up common features. This refactoring uses inheritance rather than composition, for reasons I'll cover later.

	package tutorial;
	
	import java.net.URI;
	
	import org.junit.runner.RunWith;
	import org.openqa.selenium.WebDriver;
	import org.springframework.beans.factory.annotation.Autowired;
	import org.springframework.test.context.ContextConfiguration;
	import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
	
	@RunWith(SpringJUnit4ClassRunner.class)
	@ContextConfiguration(locations = { "/applicationContext-test.xml" })
	public abstract class AbstractIT {
	
		@Autowired
		private URI siteBase;
	
		@Autowired
		private WebDriver drv;
	
		public URI getSiteBase() {
			return siteBase;
		}
	
		public WebDriver getDrv() {
			return drv;
		}
	}

	package tutorial;
	
	import static org.junit.Assert.assertTrue;
	
	import org.junit.Test;
	
	public class IndexPageIT extends AbstractIT {
	
		@Test
		public void testWeSeeHelloWorld() {
			getDrv().get(getSiteBase().toString());
			assertTrue(getDrv().getPageSource().contains("Hello World"));
		}
	}

<h2>Page Objects</h2>

A "page object" is an object that encapsulates a single instance of a page, and provides a programatic API to that instance. A basic page might be:

	package tutorial;
	
	import java.net.URI;
	
	import org.openqa.selenium.WebDriver;
	
	public class IndexPage {
	
		/**
		 * @param drv
		 *            A web driver.
		 * @param siteBase
		 *            The root URI of a the expected site.
		 * @return Whether or not the driver is at the index page of the site.
		 */
		public static boolean isAtIndexPage(WebDriver drv, URI siteBase) {
			return drv.getCurrentUrl().equals(siteBase);
		}
	
		private final WebDriver drv;
		private final URI siteBase;
	
		public IndexPage(WebDriver drv, URI siteBase) {
			if (!isAtIndexPage(drv, siteBase)) { throw new IllegalStateException(); }
			this.drv = drv;
			this.siteBase = siteBase;
		}
	}

Note that I've provided a static method to return whether or we are at the index page, and I've commented it (debatably unnecessarily for such a self-documating method); page objects form an API and can be worthwhile documenting. You'll also see that we throw an exception if the URL is incorrect. It's worth considering what condition you use to identify pages. Anything that might change (e.g. the page title, which could change between languages) is probably a poor choice. Something unchanging and machine readable (e.g. the page's path) are good choices; if you want to change the path, then you'll need to change test.

Now lets create ourself a problem. I'd like to add this to index.jsp, but the HTML produced is un-parsable:

	<% throw new RuntimeException(); %>

Instead we'll create a new servlet, but first we'll need to add the servlet-api to the pom.xml:

	<dependency>
		<groupId>javax.servlet</groupId>
		<artifactId>servlet-api</artifactId>
		<version>2.5</version>
		<scope>provided</scope>
	</dependency>

	package tutorial;
	
	import java.io.IOException;
	import javax.servlet.ServletException;
	import javax.servlet.http.HttpServlet;
	import javax.servlet.http.HttpServletRequest;
	import javax.servlet.http.HttpServletResponse;
	
	public class IndexServlet extends HttpServlet {
		private static final long serialVersionUID = 1L;
	
		protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
			throw new RuntimeException();
		}
	}

Add it to the web.xml and remove the now unnecessary welcome page:

	<!DOCTYPE web-app PUBLIC
	 "-//Sun Microsystems, Inc.//DTD Web Application 2.3//EN"
	 "http://java.sun.com/dtd/web-app_2_3.dtd" >
	<web-app>
		<servlet>
			<servlet-name>IndexServlet</servlet-name>
			<servlet-class>tutorial.IndexServlet</servlet-class>
		</servlet>
		<servlet-mapping>
			<servlet-name>IndexServlet</servlet-name>
			<url-pattern>/</url-pattern>
		</servlet-mapping>
	</web-app>

Update IndexPageIT:

		@Test
		public void testWeSeeHelloWorld() {
			getDrv().get(getSiteBase().toString());
	
			new IndexPage(getDrv(), getSiteBase());
		}

Run the test again. It passes. This might not be the behaviour you want. Selenium does not provide a way to check the HTTP status code via a WebDriver instance. Nor is the default error page sufficiently consistent between containers (compare this to what happens if you run on Tomcat for example); we cannot make assumptions about the error page's content to figure out if an error occurred.

Our index page currently does not have any machine readable features that allow us to tell it from an error page.

To tidy up, modify the servlet to display index.jsp:

		protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
			getServletContext().getRequestDispatcher("/index.jsp").forward(request, response);
		}

Currently index.jsp is a little too simple. Create a new page named create-order.jsp alongside index.jsp, and create a link on index.jsp to that page. We can create a new class for the order page, and a method that navigates us from the index page to the order page.

Add the following to index.jsp:

	<a href="create-order.jsp">Create an order</a>

create-order.jsp can be blank for now. We can also create a page object for it:

	package tutorial;
	
	import java.net.URI;
	
	import org.openqa.selenium.WebDriver;
	
	public class CreateOrderPage {
		public static boolean isAtCreateOrderPage(WebDriver drv, URI siteBase) {
			return drv.getCurrentUrl().equals(siteBase.toString() + "create-order.jsp");
		}
	
		private final WebDriver drv;
		private final URI siteBase;
	
		public CreateOrderPage(WebDriver drv, URI siteBase) {
			if (!isAtCreateOrderPage(drv, siteBase)) { throw new IllegalStateException(); }
			this.drv = drv;
			this.siteBase = siteBase;
		}
	}

Add the following dependency to pom.xml which will give us some useful annotations:

	<dependency>
		<groupId>org.seleniumhq.selenium</groupId>
		<artifactId>selenium-support</artifactId>
		<version>2.19.0</version>
		<scope>test</scope>
	</dependency>

We can flesh out IndexPage now:

		@FindBy(css = "a[href='create-order.jsp']")
		private WebElement createOrderLink;
	
		public IndexPage(WebDriver drv, URI siteBase) {
			if (!isAtIndexPage(drv, siteBase)) { throw new IllegalStateException(); }
			PageFactory.initElements(drv, this);
			this.drv = drv;
			this.siteBase = siteBase;
		}

This call to PageFactory.initElements will populate fields annotated with @FindBy with the object matching the element on the web page. Note the use of a CSS selector, it's to target the link in way that is unlikely to change. Other methods include matching elements on the page using the link text (which might change for different languages).

We can now create a method on IndexPages which navigates to CreateOrderPages.

		public CreateOrderPage createOrder() {
			createOrderLink.click();
			return new CreateOrderPage(drv, siteBase);
		}

Finally we can create a test for this link in IndexPageIT:

		@Test
		public void testCreateOrder() {
			getDrv().get(getSiteBase().toString());
	
			new IndexPage(getDrv(), getSiteBase()).createOrder();
	
			assertTrue(CreateOrderPage.isAtCreateOrderPage(getDrv(), getSiteBase()));
		}

Execute mvn verify and you should find the new test passes. At this point we have two tests that do not clean up between them. They use the same WebDriver instance for both tests, the last page will still be open and any cookies that were set will remain so. There are pros and cons of creating a single instance of a WebDriver for several tests. The main pro being reducing time cost of opening and closing browsers, but a con being that the browser is effectively left dirty after each test, cookies set, pop-ups open. We can make sure it is clean before each test  with a suitable setUp method in AbstractIT:

		@Before
		public void setUp() {
			getDrv().manage().deleteAllCookies();
			getDrv().get(siteBase.toString());
		}

There are alternative approaches to this, I'll leave it up to you to look into ways of creating a new WebDriver instance prior the each test.

The @FindBy annotation is especially useful when used on forms. Add a new form to create-order.jsp:

		<form method="post" name="create-order">
			Item: <input name="item"/> <br/>
			Amount: <input name="amount"/><br/>
			<input type="submit"/>
		</form>

Add those WebElements to CreateOrderPage , and a method to submit the form:

		@FindBy(css = "form[name='create-order'] input[name='item']")
		private WebElement itemInput;
	
		@FindBy(css = "form[name='create-order'] input[name='amount']")
		private WebElement amountInput;
	
		@FindBy(css = "form[name='create-order'] input[type='submit']")
		private WebElement submit;
	
		public CreateOrderPage(WebDriver drv, URI siteBase) {
			if (!isAtCreateOrderPage(drv, siteBase)) { throw new IllegalStateException(); }
			PageFactory.initElements(drv, this);
			this.drv = drv;
			this.siteBase = siteBase;
		}
		
		public CreateOrderPage submit(String item, String amount) {
			itemInput.sendKeys(item);
			amountInput.sendKeys(amount);
			submit.click();
			return new CreateOrderPage(drv, siteBase);
		}

Finally we can create a test for this:

	package tutorial;
	
	import static org.junit.Assert.*;
	
	import org.junit.Test;
	
	public class CreateOrderPageIT extends AbstractIT {
	
		@Test
		public void testSubmit() {
			new IndexPage(getDrv(), getSiteBase()).createOrder().submit("foo", "1.0");
		}
	}

<h2>Conclusion</h2>

One thing you might note is that the submit method doesn't require the amount to be a number as you might expect. You could create a test to see that submitting a string instead of a number. Integration tests can be time consuming to write and vulnerable to breaking as a result of changes to things such as the ID of an element, or name of an input. As a result the greatest benefit to be gained from creating them is initially create them just on business critical paths within your site, for example, product ordering, customer registration processes and payments.

In the next part of this tutorial, we'll looking at backing the tests with some data, and the challenges this engenders.

This tutorial is <a href="https://github.com/alexec/tutorial-selenium">on Github</a>.

You might be interesting in using <a href="/content/tomcat-context-junit-rule">my JUnit @Rule for Tomcat</a>.
