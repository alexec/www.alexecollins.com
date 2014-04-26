---
title: Geb, Selenium, Cucumber & Maven Tutorial
date: 2014-01-26 09:53 UTC
tags: geb, selenium, cucumber, maven, testing, tutorial
---
A while ago I wrote some [tutorials](/tags/selenuim.html) on writing Selenium tests in Java. I've been using Selenium on and off for a while and I've found somethings are always tricky:

* The Java code tends to be very verbose and has a lot of boiler plate. But you're not tied to the backend language, so you could use any language, or even a DSL.
* JUnit is great for unit testing, but it's not really ideal for functional tests. These tests could be Product Owner facing, and framework choice should suite this.
* I've found that the main drivers (e.g the Firefox driver) can be slow, prone to crashing, or not cleaning up after themselves.

It struck me that I needed to research an alternative, so this led me to the following stack:

* HtmlUnit driver rather than FirefoxDriver. While it's not a featured as the other drivers, it's faster and more reliable.
* Geb for defining pages, navigating and assertions. 
* Cucumber Groovy for creating test scenarios. It's really well known and understood, integration with major IDE and build tools is mature.

I've put the [code for this tutorial on Github](https://github.com/alexec/geb-maven-tutorial).

Maven Set-up
---
You can create a basic Maven web-app very easily:

	mvn archetype:generate -DgroupId=test -DartifactId=test-webapp -Dversion=1.0.0-SNAPSHOT -DarchetypeArtifactId=maven-archetype-webapp
	
We want it to run integration tests, so add the Cargo and Failsafe plugins:

~~~xml
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
<plugin>
    <artifactId>maven-failsafe-plugin</artifactId>
    <executions>
        <execution>
            <goals>
                <goal>integration-test</goal>
                <goal>verify</goal>
            </goals>
        </execution>
    </executions>
</plugin>
~~~

You can now execute `mvm cargo:run` to run a local server for testing, or `mvm install` to run tests automatically.
	
Groovy Set-up
---
As Geb is Groovy based, and some of our code will be in Groovy, we'll need the correct, matching, compiler and dependencies. There are a few options to do this, I've found this combination to be most reliable (note I'm using v1.8):

~~~xml
<plugin>
    <groupId>org.codehaus.gmaven</groupId>
    <artifactId>gmaven-plugin</artifactId>
    <executions>
        <execution>
            <goals>
                <goal>generateTestStubs</goal>
                <goal>testCompile</goal>
            </goals>
            <configuration>
                <providerSelection>1.8</providerSelection>
            </configuration>
        </execution>
    </executions>
</plugin>
...
<dependency>
    <groupId>org.codehaus.groovy</groupId>
    <artifactId>groovy-all</artifactId>
    <version>1.8.6</version>
    <scope>test</scope>
</dependency>
~~~

Geb Set-up
---
We'll need some Geb/Selenium dependencies:

~~~xml
<dependency>
    <groupId>org.gebish</groupId>
    <artifactId>geb-core</artifactId>
    <version>0.9.2</version>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.seleniumhq.selenium</groupId>
    <artifactId>selenium-htmlunit-driver</artifactId>
    <version>2.36.0</version>
    <scope>test</scope>
</dependency>
~~~

Geb requires some basic config stating which driver to use and when to navigate relative to, in the form of a `GebConfig.groovy` file is the class path root:

	driver = "htmlunit"
	baseUrl = "http://localhost:8080/test-webapp/"

Cucumber Set-up
---
Again, we'll need some dependencies:

~~~xml
<dependency>
    <groupId>info.cukes</groupId>
    <artifactId>cucumber-junit</artifactId>
    <version>1.1.5</version>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>info.cukes</groupId>
    <artifactId>cucumber-groovy</artifactId>
    <version>1.1.5</version>
    <scope>test</scope>
</dependency>
~~~

We'll need a single test so that Maven runs it during the integration-test phase:

~~~groovy
@RunWith(Cucumber.class)
class RunCukesIT {
}
~~~

Putting it Together
---
To bind Geb and Cucumber we need an `env.groovy` that lives with the step defs:

~~~java
package stepdefs

import geb.Browser
import geb.binding.BindingUpdater

import static cucumber.api.groovy.Hooks.After
import static cucumber.api.groovy.Hooks.Before

Before() {
    bindingUpdater = new BindingUpdater(binding, new Browser())
    bindingUpdater.initialize()
}

After() {
    bindingUpdater.remove()
}
~~~

Phew! That's the boiler plate over and done with! Fortunately, you only need to do it once, and you're not going to see too much Groovy code from now on. Instead, much of the code will be DSL-ish.

The first thing we'll need is a couple of [page objects](https://code.google.com/p/selenium/wiki/PageObjects). I'm including one for the index and one for a create order page, e.g.:

~~~groovy
package pages

import geb.Page

class CreateOrderPage extends Page {
    static url = "create-order.jsp"
    static at = { $("h2").text() == "Create Order" }
    static content = {
        form { $("form") }
        item { form.find("input[name='item']") }
        amount { form.find("input[name='amount']") }
        submit { form.find("input[type='submit']") }
    }

    def createOrder(item1, amount1) {
        item = item1
        amount = amount1
        submit.click()
    }
}
~~~

This page object class provides a few things:

* `url` is the path to the page, relative to the `baseUrl` in the config.
* `at` is a closure that verifies you're on the page.
* `content` creates a series of fields on the page object mapped to page elements, in this case a form.
* `createOrder` is a method that fills the form and submits it.

The step defs provides an insight in how we use the pages:

~~~groovy
package stepdefs

import pages.CreateOrderPage
import pages.IndexPage

import static cucumber.api.groovy.EN.*

Given(~"I'm at the index page") { ->
    to IndexPage
    at IndexPage
}
When(~"I click 'Create Order'") { ->
    page.clickCreateOrder()
}
Then(~"I see the create order page") { ->
    at CreateOrderPage
}
Given(~"I'm at the create order page") { ->
    to CreateOrderPage
    at CreateOrderPage
}
When(~"I enter (.*) (.*)") { item, amount ->
    page.createOrder(item, amount)
}
~~~

This file uses `at` and `to` from Geb to navigate to the appropriate pages, and the implicit `page` object to access the page You can see two examples here, `page.clickCreateOrder()` refers to the index page, whereas `page.createOrder(..)` refers to the order page.

Finally, you can create `create-order.feature`:

~~~gherkin
Feature: Create Order

  Scenario: Navigate to Create Order
    Given I'm at the index page
    When I click 'Create Order'
    Then I see the create order page

  Scenario: Input Order
    Given I'm at the create order page
    When I enter test 1.0
    Then I'm at the create order page
~~~

You can now run the `RunCukesIT` or the `create-order.feature` within your IDE (after starting Cargo), or as part of a build using `mvn install`. 

Exercise for the Reader
---
Check out the code, add a new order confirmation page and create a test scenario for it.

Conclusion
---
Combining Geb with Cucumber provides a compact, expressive, and PO/QA friendly way to create browser tests. Using  the HTML Unit driver provides speed and reliability, but at the expense of power. Using Groovy instead of Java provides a terser way to write tests, which reduces boiler, plate and takes advantage of Groovy's closures.

Geb is currently v0.9.2. I've not had problems with the libraries, and you'll find that hunting down tutorials (such as this one) can be very helpful. Some of the examples are incomplete, or out dated and hopefully this tutorial will help

References
---
* [The Book of Geb (Geb's manual)](http://www.gebish.org/)
* [Spock version on Github](https://github.com/alexec/geb-maven-tutorial/releases/tag/spock)
* [Geb Grails Tutorial](https://github.com/hauner/grails-cucumber/wiki/Testing-Grails-with-Cucumber-and-Geb)