---
# TODO - rename
title: Practical Java Domain Specific Language Tutorial
date: 2015-09-19 17:08 UTC
tags: groovy, dsl, java, webdriver, selenium
---
This tutorial will teach you how to create a **Domain Special Language (DSL)** for testing web pages. you'll be taking the canonical **Selenium WebDriver** hello world -- searching using Google, and use it to write a DSL.

You'll need to be familiar with Java, Maven, and WebDriver would be handy.

As usual, the code can be found on [Github](https://github.com/alexec/wd-dsl).

To start with, create the following `pom.xml`

~~~xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xmlns="http://maven.apache.org/POM/4.0.0"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>wd-dsl</groupId>
    <artifactId>wd-dsl</artifactId>
    <version>1.0.0-SNAPSHOT</version>

    <properties>
        <selenium.version>2.47.0</selenium.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.codehaus.groovy</groupId>
            <artifactId>groovy</artifactId>
            <version>2.4.3</version>
        </dependency>
        <!-- test -->
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.12</version>
        </dependency>
        <dependency>
            <groupId>org.seleniumhq.selenium</groupId>
            <artifactId>selenium-firefox-driver</artifactId>
            <version>${selenium.version}</version>
        </dependency>
        <dependency>
            <groupId>org.seleniumhq.selenium</groupId>
            <artifactId>selenium-support</artifactId>
            <version>${selenium.version}</version>
        </dependency>
    </dependencies>

</project>
~~~

Let's start with a failing test:

~~~java
import org.junit.Test;

public class WebDriverDslTest {
    @Test
    public void canRunExample() throws Exception {
        WebDriverDsl.run("search-google.groovy");
    }
}
~~~

And fill out the stub implementation:

~~~java
public class WebDriverDsl {
    public static void run(String script) {
        // TODO
    }
}
~~~

Not much to look at yet, but lets create an example file for the DSL (save it as `src/test/resources/example.groovy`):

~~~groovy
wd {
    go "http://www.google.com"
    set "#lst-ib", "WebDriver Tutorials"
    click "button[type='submit']"
    assert get("Selenium Tutorials").displayed
}
~~~

Does the syntax look familiar? This is in fact a valid Groovy program, but this requires something boiler plate code to run, so update your class with these lines:

~~~java
public static void run(String script) throws IOException {
    run(WebDriverDSL.class.getResourceAsStream(script));
}

public static void run(InputStream resource) throws IOException {
    WebDriverDSL dsl = new WebDriverDSL();
    InputStreamReader in = new InputStreamReader(resource);
    new GroovyShell(new Binding(Collections.singletonMap("wd", dsl)))
            .parse(in)
            .run();
}

void call(Closure cl) {
    cl.setDelegate(this);
    cl.setResolveStrategy(Closure.DELEGATE_ONLY);
    cl.call();
}
~~~

Those lines are pure boiler-plate scaffolding. I'm not going to explain them in any detail, except to say that it tells the Groovy shell how to bind the script to the DSL class.

Now, try and run your test, you'll get an error:

~~~
groovy.lang.MissingMethodException: No signature of method: Script1$_run_closure1.go() is applicable for argument types: (java.lang.String) values: [http://www.google.com]
~~~

This is telling us that `WebDriverDsl` is missing a method, so lets add a new field and a new method:

~~~java
private final WebDriver driver = new FirefoxDriver();

public void go(String location) {
    driver.get(location);
}
~~~

WebDriver should be quit before you close you program, otherwise you might get many open browser which will ultimately crash your computer. Lets update the class to implement `AutoCloseable`, and implement the `close` method:

~~~java
@Override
public void close() {
    driver.quit();
}
~~~

Finally, you need to close it when done, so update the `run` method:

~~~java
public static void run(InputStream resource) throws IOException {
    try (WebDriverDSL dsl = new WebDriverDSL()) {
        InputStreamReader in = new InputStreamReader(resource);
        new GroovyShell(new Binding(Collections.singletonMap("wd", dsl)))
                .parse(in)
                .run();
    }
}
~~~

Run the test again, you'll see Firefox open up and open the Google search page -- we're making progress. This time you'll see a new error:

~~~
groovy.lang.MissingMethodException: No signature of method: Script1$_run_closure1.set() is applicable for argument types: (java.lang.String, java.lang.String) values: [#lst-ib, WebDriver Tutorials]
~~~

You can implement this, and we also need to implement the other methods, so let's do them all at once:

~~~java
public void set(String locator, String value) {
    driver.findElement(By.cssSelector(locator)).sendKeys(value);
}

public void click(String locator) {
    driver.findElement(By.cssSelector(locator)).click();
}
~~~

Now you have a fully formed, mini-DSL. You can add words to your DSL until you're happy with it!
