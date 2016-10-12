---
title: Spring Boot Performance
date: 2015-09-05 09:03 UTC
tags: spring, spring boot, performance, java
---
This is an article on how to improve the performance of Spring Boot applications. I've recently been working on a new project. As we primarily use Java and Spring, we've been looking at **Spring Boot**.  It's allowed us to get up and running quickly. 

Early on, I came across a problem with a prototype for one of our new applications. It was loading the Velocity web page template engine. I could not understand why -- it was just some REST services, no web pages. I spent a bit of time looking into this issue, and how to improve the performance of Spring Boot applications, and this is what I found.

Component Scanning Slows Start-up
---
By default, you may find yourself using the [`@SpringBootApplication`](http://docs.spring.io/spring-boot/docs/current/api/org/springframework/boot/autoconfigure/SpringBootApplication.html) annotation to get your application configured automatically. This has a couple of side-effects. One is to enable **component scanning**. This looks through the classes to find ones annotated with Spring "stereotypes", such as `@Component`. This is convenient, especially when you start out, but it has two side-effects:

1. It slows application start-up time. This will have a greater impact if you have a large application, or a large number of integration tests that need to start up the application to run.
2. It may load beans you don't want or need. 

You can disable component scanning by removing the `@SpringBootApplication` and `@ComponentScan` annotations. You'll then need to make each bean explicit in your configuration.

~~~java
// remove @SpringBootApplication and @ComponentScan, replace with @EnableAutoConfiguration
@Configuration
@EnableAutoConfiguration
public class SampleWebUiApplication {

	// ...

	// you must explicitly list all beans that were being component scanned	@Bean
	public MessageController messageController(MessageRepository messageRepository) {
		return new MessageController(messageRepository);
	}
~~~

Auto-Configuration Can Load More Than You Need
---
The `@SpringBootApplication` annotation implies the `@EnableAutoConfiguration` annotation. This enables auto-configuration. This can load components you don't need, slowing application start-up and increasing memory and CPU usage. Lets look at how to use this in a more controlled fashion.

If you start your application using `-Ddebug` it'll print a report of the components it auto-configures:

~~~bash
mvn spring-boot:run -Ddebug
…
=========================
AUTO-CONFIGURATION REPORT
=========================


Positive matches:
-----------------

   DispatcherServletAutoConfiguration
      - @ConditionalOnClass classes found: org.springframework.web.servlet.DispatcherServlet (OnClassCondition)
      - found web application StandardServletEnvironment (OnWebApplicationCondition)

...
~~~

Copy the classes mentioned in the ""positive matches" section of the report:

~~~
DispatcherServletAutoConfiguration
EmbeddedServletContainerAutoConfiguration
ErrorMvcAutoConfiguration
HttpEncodingAutoConfiguration
HttpMessageConvertersAutoConfiguration
JacksonAutoConfiguration
JmxAutoConfiguration
MultipartAutoConfiguration
ServerPropertiesAutoConfiguration
PropertyPlaceholderAutoConfiguration
ThymeleafAutoConfiguration
WebMvcAutoConfiguration
WebSocketAutoConfiguration
~~~

Update your configuration to explicitly import them, and run your tests to make sure everything is OK.

~~~java
@Configuration
@Import({
        DispatcherServletAutoConfiguration.class,
        EmbeddedServletContainerAutoConfiguration.class,
        ErrorMvcAutoConfiguration.class,
        HttpEncodingAutoConfiguration.class,
        HttpMessageConvertersAutoConfiguration.class,
        JacksonAutoConfiguration.class,
        JmxAutoConfiguration.class,
        MultipartAutoConfiguration.class,
        ServerPropertiesAutoConfiguration.class,
        PropertyPlaceholderAutoConfiguration.class,
        ThymeleafAutoConfiguration.class,
        WebMvcAutoConfiguration.class,
        WebSocketAutoConfiguration.class,
})
public class SampleWebUiApplication {
~~~
 
I can see that both JMX and web sockets are listed, but I know I'm not using them. I can delete them, and any other dependencies I don't need, to get a performance improvement.  Run your tests again to make sure everything is OK.

Change Servlet Container To Undertow
---
By default, Spring Boot uses Tomcat. Tomcat uses around 110mb of heap, and has ~16 threads: 

![tomcat](/images/tomcat-spring-boot-jvisualvm.png)

Undertow is a lightweight servlet container from JBoss. You can [switch to Undertow](http://docs.spring.io/spring-boot/docs/current/reference/html/howto-embedded-servlet-containers.html#howto-use-undertow-instead-of-tomcat) to get a performance improvement. Firstly, exclude Tomcat from your dependencies:

~~~xml
<exclusions>
        <exclusion>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-starter-tomcat</artifactId>
        </exclusion>
</exclusions>
~~~         
    
Add Undertow:    
    
~~~xml
<dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-undertow</artifactId>
</dependency>
~~~                

Undertow uses around 90MB and has ~13 threads: 

![undertow](/images/undertow-spring-boot-jvisualvm.png)

Conclusion
---
These are a few small tips on improving the performance of your Spring Boot applications. The benefits are smaller for smaller applications, but for larger applications can quickly become pronounced. Try it out and tell me what you think.

As usual, [the code is on Github](https://github.com/alexec/spring-boot-performance).

References
---
* <https://www.techempower.com/benchmarks/>
* <https://cloud.google.com/appengine/articles/spring_optimization>