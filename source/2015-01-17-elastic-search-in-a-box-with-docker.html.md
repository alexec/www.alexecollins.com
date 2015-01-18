---
title: Search In A Box With Docker, Elastic Search, and Selenium
date: 2015-01-17 09:43 UTC
tags: docker, maven, elastic search, testing, selenium
---
Overview
===
This tutorial will show you how to build a search service in a box. It'll have a graphical front end to search for some funny jokes (well, they made me laugh). Notably, you'll be able to build, test, and package it into a container with a push of a button.

We'll learn about:

* Searching and indexing with [Elastic Search](http://www.elasticsearch.org),
* Creating a standalone web-app with [Spring Boot](http://projects.spring.io/spring-boot/),
* Building Docker containers with [Docker Maven Plugin](https://github.com/alexec/docker-maven-plugin),
* Testing with [Selenide](http://selenide.org) and [Selenium WebDriver](http://docs.seleniumhq.org/projects/webdriver/).

As always, you can checkout the [code on Github](https://github.com/alexec/search-in-a-box).

Prerequisites
---
You'll need to have installed:

* Maven,
* Java (version 7 or later),
* Docker (or, if you're on a Mac: [Boot2Docker](http://boot2docker.io)).

Preparation
---
Lets create a `pom.xml` file for our project:

~~~xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>search-in-a-box</groupId>
    <artifactId>search-in-a-box</artifactId>
    <version>1.0.0-SNAPSHOT</version>

</project>
~~~

Create The Basic Search Query Page
---

We're going to build this using [Acceptance Test Driven Development (ATDD)](http://en.wikipedia.org/wiki/Acceptance_test-driven_development). As this will be a web application, we're going to use Selenide, a simple DSL that works with Selenium WebDriver to test web apps. Add these dependencies to get started:

~~~xml
<dependency>
    <groupId>junit</groupId>
    <artifactId>junit</artifactId>
    <version>4.12</version>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>com.codeborne</groupId>
    <artifactId>selenide</artifactId>
    <version>2.16</version>
    <scope>test</scope>
</dependency>
~~~

We'll create a test that verifies the homepage shows a search box:

~~~java
package searchinabox;

import org.junit.Test;
import org.openqa.selenium.By;

import static com.codeborne.selenide.Condition.exist;
import static com.codeborne.selenide.Selenide.$;
import static com.codeborne.selenide.Selenide.open;

public class AppIT {

    @Test
    public void homepageShowsSearchBox() throws Exception {
        open("/");
        $(By.cssSelector("input[name='query']")).should(exist);
    }
}
~~~

Run this test and you'll find it is red. We need to get our search page running!

We're going to create a Spring Boot application. Add these lines to your `pom.xml`:

~~~xml
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>1.2.1.RELEASE</version>
</parent>
~~~

This will sort out our dependency versions for us. Next, we'll be using Spring Boot with Thyme-leaf for templates. Add the Spring Boot dependency:

~~~xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-thymeleaf</artifactId>
</dependency>
~~~

Next, create an application class, this will

1. Expose the home page,
2. Boot up the application.

~~~java
@SpringBootApplication
@Controller
public class App {

    @RequestMapping("/")
    public String home() {
        return "home";
    }

    public static void main(String[] args) {
        SpringApplication.run(App.class, args);
    }
}
~~~

We need some HTML for the home page, so make `src/main/resources/templates/home.html`:

~~~html
<!DOCTYPE HTML>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <title>Search In A Box</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
</head>
<body>
<form method="post">
    <input name="query"/>
    <input type="submit"/>
</form>
</body>
</html>
~~~

When you run the application, you can then run the test and see that it is green. You can also look at the search form manually at <http://localhost:8080>.

Searching For Jokes
---
Sticking with ATDD, create the test first:

~~~java
@Test
public void searchingForBearsFindsTheNorthPollJoke() throws Exception {

    open("/");
    $(By.name("query")).sendKeys("bears");
    $(By.cssSelector("input[type='submit']")).submit();

    $$(By.tagName("td")).find(exactText("The North Poll!")).should(exist);
}
~~~

We need to speak to a client, so create the following Spring Java configuration file:

~~~java
@Configuration
public class Config {

    @Bean(destroyMethod = "close")
    public Node node() {
        return NodeBuilder.nodeBuilder().node();
    }

    @Bean
    public Client client() {
        return node().client();
    }
}
~~~

Elastic Search creates directory called `data` in the root of our project. We want this to be cleaned for testing, so we can set-up the Maven Clean Plugin to do so

~~~xml
<plugin>
    <artifactId>maven-clean-plugin</artifactId>
    <configuration>
        <filesets>
            <fileset>
                <directory>data</directory>
            </fileset>
        </filesets>
    </configuration>
</plugin>
~~~

We want to make a service for indexing and searching jokes. There's will be quite a bit going on here, so let's break it down:

1. On start-up create an index called "jokes" to store our jokes in,
2. Then we store two jokes, each with unique IDs,
3. Finally, we provide a method to search for jokes.

~~~java
@Service
public class JokeSearchService {

    @Autowired
    private Client client;

    @PostConstruct
    public void indexJokes() throws Exception {
        // create an index name "jokes" to store the jokes in
        try {
            client.admin().indices().prepareCreate("jokes").get();
        } catch (IndexAlreadyExistsException ignored) {
        }

        storeJoke(1, "Why are teddy bears never hungry? ", "They are always stuffed!");
        storeJoke(2, "Where do polar bears vote? ", "The North Poll!");
    }

    private void storeJoke(int id, String question, String answer) throws IOException {
        // index a document ID  of type "joke" in the "jokes" index
        client.prepareIndex("jokes", "joke", String.valueOf(id))
                .setSource(
                        XContentFactory.jsonBuilder()
                                .startObject()
                                .field("question", question)
                                .field("answer", answer)
                                .endObject()
                )
                .get();
    }

    public SearchHit[] search(String query) {
        return client.prepareSearch("jokes")
                .setTypes("joke")
                .setQuery(QueryBuilders.multiMatchQuery(query, "question", "answer"))
                .get().getHits().getHits();
    }
}

~~~

Update the `App` and add the following lines so the we have can accept POST requests and display results:

~~~java
@Autowired
private JokeSearchService jokeSearchService;

@RequestMapping(value = "/", method = RequestMethod.POST)
public String search(@RequestParam("query") String query, Model model) {
    model.addAttribute("results", jokeSearchService.search(query));
    return "results";
}
~~~

Next, we need a results page so create `src/main/resources/templates/results.html`:

~~~html
<!DOCTYPE HTML>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <title>Search In A Box - Results</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
</head>
<body>
<table>
    <tr th:each="result : ${results}">
        <td th:text="${result.source.question}"/>
        <td th:text="${result.source.answer}"/>
    </tr>
</table>
</body>
</html>
~~~

Restart the application, run the test, and you'll see it's green.

Putting The Application Into A Container
---
We want to put the application into a Docker container. Spring Boot can create a standalone jar to put it into the container, so add this plugin to the `pom.xml`:

~~~xml
<plugin>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-maven-plugin</artifactId>
</plugin>
~~~

You can see this at work by creating a package:

~~~bash
$ mvn package
...
spring-boot-maven-plugin:1.2.1.RELEASE:repackage 
~~~

This replaces the original JAR, with a standalone version.

Next, we'll use a plugin to build the container:

~~~xml
<plugin>
    <groupId>com.alexecollins.docker</groupId>
    <artifactId>docker-maven-plugin</artifactId>
    <version>2.3.1</version>
    <dependencies>
        <!-- only needed if you are using Boot2Docker -->
        <dependency>
            <groupId>com.alexecollins.docker</groupId>
            <artifactId>docker-java-orchestration-plugin-boot2docker</artifactId>
            <version>2.3.1</version>
        </dependency>
    </dependencies>
</plugin>
~~~

The plugin neees some files to create the app, so in `src/main/docker/searchinabox` create  a `Dockerfile` that:

1. Adds the JAR, 
2. Adds a configuration file,
3. Exposes the port - both our app on 8080, and Elastic Search on 9200 and 9300,
4. Sets the start-up command (which also set the classpath to allow us to load the config).

~~~
FROM dockerfile/java:oracle-java7

EXPOSE 8080
EXPOSE 9200
EXPOSE 9300

ADD ${project.build.finalName}.jar .

CMD java -jar /${project.build.finalName}.jar
~~~

We need a `conf.yml` file in the same directory, this:

1. Indicates which to add JAR into the packing directory,
2. States the ports to expose on the host,
4. A health check URL we can use to smoke test the container, 
5. Finally a tag for the container so we can easily identify it:

~~~yml
packaging:
  add:
    - target/${project.build.finalName}.jar
ports:
  - 8080
  - 9200
  - 9300
healthChecks:
  pings:
    - url: http://localhost:9200/
    - url: http://localhost:8080/
tag:
    searchinabox/app:${project.version}
~~~

To package this andstart-up the container:

~~~bash
mvn docker:start
~~~

You should see this:

~~~
[INFO] Starting searchinabox
...
[INFO] BUILD SUCCESS
~~~

The container will be listed by the `docker` command

~~~bash
$ docker ps
alex-collinss-macbook:esiab alexc$ docker ps
CONTAINER ID        IMAGE                             COMMAND                CREATED             STATUS              PORTS                                                                    NAMES
f673731a9489        searchinabox/searchinabox:1.0.0-SNAPSHOT   "/bin/sh -c 'java  -   6 seconds ago       Up 4 seconds        0.0.0.0:8080->8080/tcp, 0.0.0.0:9200->9200/tcp, 0.0.0.0:9300->9300/tcp   search-in-a-box_app  
~~~

We can check we can access Elastic Search by opening the <http://localhost:9200> URL, and our application by opening <http://localhost:8080>.

Packing containers can go wrong. You can find you can print/tail the logs of the last started container with this useful command:

~~~bash
docker logs -f $(docker ps -qa|head -n1)
~~~

We often want to start the container up with a shell to debug it, for example I often get the start command wrong, so here's what I'd do:

~~~bash
docker run -t -i  searchinabox/searchinabox:1.0.0-SNAPSHOT bash
~~~

Continuous Integration
---
To complete the picture we want to start the containers and run the acceptance tests. We'll use the Maven Failsafe Plugin to do the tests, so add this plugin as so:

~~~xml
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

Add the appropriate execution to the `docker-maven-plugin`:

~~~xml
<executions>
    <execution>
        <goals>
            <goal>clean</goal>
            <goal>start</goal>
            <goal>stop</goal>
        </goals>
    </execution>
</executions>
~~~

Finally, let test it.

~~~bash
mvn clean verify
...
[info] BUILD SUCCESSFUL
~~~

Conclusion
---
We seen how to create a search service in a box with Elastic Search, Spring Boot and Docker. We've seen how to create a build using Docker Maven Plugin. Here are some exercises for the reader:

* The UI is pretty drab, how about an attractive [Bootstrap](http://getbootstrap.com) front end?
* We've let the model leak into the templates. We also have to speak to Elastic Search directly. Perhaps we should refactor it so that we speak to an intermediate bean that abstracts that away?
* We're not indexing a lot of things? Should we some new indexers for other items?