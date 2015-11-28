---
title: Java Annotation Processor Tutorial
date: 2014-11-06 22:20 UTC
tags: java, annotation processor, sprint, annotation tutorial
---
I've been using [Project Lombok](http://projectlombok.org), the excellent Java tool that create value-object classes with minimal code. Under the hood it uses the [Java Annotation Processor](http://docs.oracle.com/javase/7/docs/api/javax/annotation/processing/Processor.html) to generate code based on your source code before compilation. Annotation processing a somewhat niche technique, but it has some great use cases. Lombok uses it for generate code, but another good use it to verify your source code.

In a [recent tutorial](http://www.alexecollins.com/spring-transactional-gotchas/), I showed how Spring `@Transactional` annotation can cause problems. Today we'll write an annotation processor to identify these prevent these problems at compile time.

All the following code can be found on [Github](https://github.com/alexec/spring-tx-ann-proc).

Create the following basic `pom.xml`:

~~~xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>spring-tx-ann-proc</groupId>
    <artifactId>spring-tx-ann-proc</artifactId>
    <version>1.0.0-SNAPSHOT</version>

    <build>
        <plugins>
            <plugin>
                <artifactId>maven-compiler-plugin</artifactId>
                <configuration>
                    <compilerArgument>-proc:none</compilerArgument>
                </configuration>
            </plugin>
        </plugins>
    </build>
    
</project>
~~~

Unless we disable processors for this project using `-proc:none`, then it'll try to process itself!

We need a file to tell the Java complier where to find our new processor, so create `src/main/resources/META-INF/services/javax.annotation.processing.Processor`:

~~~
SpringTransactionalProcessor
~~~

Next, create this small class:

~~~java
@SupportedAnnotationTypes("org.springframework.transaction.annotation.Transactional")
@SupportedSourceVersion(SourceVersion.RELEASE_6)
public class SpringTransactionalProcessor extends AbstractProcessor {

    @Override
    public boolean process(Set<? extends TypeElement> typeElements, RoundEnvironment roundEnvironment) {
        System.out.println("not doing much right now");
        return true;
    }
}
~~~

The class's annotations tell the Java compiler what annotation we are interested in, and the minimum Java version we support, Java 6 in this case.

Build and install our new project:

~~~
mvn install
~~~

Now, we need some code to test this out. Fortunately, I've written a project we can already use for this:

~~~
git clone https://github.com/alexec/spring-tx-gotchas.git
~~~

Open this project and add our new project as a dependency to the `pom.xml`:

~~~xml
<dependency>
	<groupId>spring-tx-ann-proc</groupId>
	<artifactId>spring-tx-ann-proc</artifactId>
	<version>1.0.0-SNAPSHOT</version>
	<scope>provided</scope>
</dependency>
~~~

Note that we use the provided scope to make sure our processor does not end up in our production systems.

Do a `mvn compile` and you should see this output:

~~~
[INFO] Compiling 1 source file to /Users/alexc/spring-tx-gotchas/target/classes
not doing much right now
~~~

We can see it's working, but we need to flesh it out.

Add this dependency to you annotation processor's `pom.xml`:

~~~xml
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-tx</artifactId>
            <version>3.2.11.RELEASE</version>
        </dependency>
~~~

And change our processor to:

~~~java
public boolean process(Set<? extends TypeElement> typeElements, RoundEnvironment roundEnvironment) {
	for (Element element : roundEnvironment.getElementsAnnotatedWith(Transactional.class)) {
		Element classElement= element.getEnclosingElement();
		boolean isPublic = element.getModifiers().contains(Modifier.PUBLIC);
		if (!isPublic) {
			processingEnv.getMessager().printMessage(Diagnostic.Kind.ERROR, classElement + "#" + element+ " is not public, but @Transactional only works with public methods");
		}
	}
	return true;
}
~~~

Firstly `mvn install` the annotation project. Then modify the Spring project so that the method is not public:

~~~java
protected void insertOneRecordAndThenThrowException() {
~~~

Finally, we can test our annotation processor works but running `mvn clean install` on the Spring project, you should now see this error:

~~~
[ERROR] Failed to execute goal org.apache.maven.plugins:maven-compiler-plugin:2.3.2:compile (default-compile) on project spring-tx-gotchas: Compilation failure
[ERROR] error: App#insertOneRecordAndThenThrowException() is not public, but @Transactional only works with public methods
~~~

Conclusion
---
This is just one use of an annotation processors. They have a number of other uses, such as documentation or source code generation, and source code validation. 