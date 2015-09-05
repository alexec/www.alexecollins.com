---
title: Spring Boot Performance
date: 2015-09-05 09:03 UTC
tags: spring, spring boot, performance, java
---
I've recently been working on a large green field project. As we primarily use Java and Spring extensively, we've been looking at **Spring Boot**.  It's allowed us to get up and running quickly. 

Early on, I can across a problem with a prototype for one of our new applications. It was loading the Velocity tempting engine. I could not figure out why -- it was just some REST services, new web pages. I spent a bit of time looking into this issue, and how to improve the performance of Spring Boot applications, as this is what I found.

Component Scanning Slows Start-up
---
By default, you can use the [`@SpringBootApplication`](http://docs.spring.io/spring-boot/docs/current/api/org/springframework/boot/autoconfigure/SpringBootApplication.html) annotation to get you application configured automatically. This has a couple of side-effects. One is to enable **component scanning**. This looks through the classes to find ones annotated with stereotypes, such as `@Component`. This is convenient, especially when you start out, and it has two side-effects:

1. It slows application start-up time. This will have greater impact if you have a large application, or a large number of integration tests that start up the application as part of each test.
2. It may load beans you don't want or need. 

You can disable component scanning by removing the `@SpringBootApplication` and `@ComponentScan` annotations. You'll then need to make each bean explicit.

~~~java
// remove annotations and replace with just EnableAutoConfiguration
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
The `@SpringBootApplication`  implies the `@EnableAutoConfiguration` annotation. This enabled auto-configuration. This can load components you don't need, slowing application start-up and increasing memory and CPU usage. Lets look at how to use this in a more controlled fashion.

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

Copy the list of positive matches in the report:

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

You can now update your configuration to explicitly import them, and run your tests to make sure everything is OK:

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
 
I can see that both JMX and web sockets are listed, but I know I'm not using them. I can delete them, and any other dependencies I don't need to get a performance improvement.

Change Servlet Container To Undertow
---
By default, Spring Boot uses Tomcat. Tomcat uses around 110mb of heap, and has 16 threads: 

![tomcat](/images/tomcat-spring-boot-jvisualvm.png)

Undertow is lightweight servlet container from JBoss. You can [switch to Undertow](http://docs.spring.io/spring-boot/docs/current/reference/html/howto-embedded-servlet-containers.html#howto-use-undertow-instead-of-tomcat) to get a performance improvement. Firstly, exclude Tomcat from your dependencies:

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

Undertow uses around 90MB and has 13 threads: 

![undertow](/images/undertow-spring-boot-jvisualvm.png)

Conclusion
---
These are a few small tips on improving the start time of your Spring Boot applications. The benefits are small for smaller application, but for large application can quickly become pronounced. Try it out and tell me what you think. 

As usual, [the code is on Github](https://github.com/alexec/spring-boot-performance).

References
---
* <https://www.techempower.com/benchmarks/>
* <https://cloud.google.com/appengine/articles/spring_optimization>