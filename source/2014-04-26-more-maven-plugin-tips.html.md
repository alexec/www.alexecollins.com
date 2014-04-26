---
title: More Maven Plugin Tips
date: 2014-04-26 19:47 UTC
tags: maven
---
I've been writing a couple more Maven plugins recently, including [one to start/stop groups of Docker containers](/content/docker-maven-plugin). I wanted to extend [my previous tips](/content/tips-writing-maven-plugins) with three new tips I've found really helpful.

Tip 7: Don't Do Any Work In Your Mojo Class
---
I've used this really effectively. Create a POJO class to do the heavy lifting for you. It's much easier to test this class without the Maven infrastructure. In my plugin I've create [DockerOrchestator](https://github.com/alexec/docker-maven-plugin/blob/master/src/main/java/com/alexecollins/docker/orchestration/DockerOrchestrator.java). This has methods such as `clean`, `start` and `stop`. 

We can create common parent class that creates the delegate:

~~~java
abstract class AbstractDockerMojo extends AbstractMojo {

    @Parameter(defaultValue = DEFAULT_HOST, property = "docker.host", required = true)
    private URI host;

    ...

    @Override
    public final void execute() throws MojoExecutionException, MojoFailureException {
        try {
	        doExecute(new DockerOrchestrator(...));
        } catch (Exception e) {
            throw new MojoExecutionException(e.getMessage(), e);
        }
    }
    
    protected abstract void doExecute(DockerOrchestrator orchestrator) throws Exception;
    ...
~~~

Then each sub-class can just call the appropriate method. There's almost nothing to test.

~~~java
@Mojo(name = "start", defaultPhase = LifecyclePhase.PRE_INTEGRATION_TEST)
public class StartMojo extends AbstractDockerMojo {

    @Override
    protected void doExecute(DockerOrchestrator orchestrator) {
        orchestrator.start();
    }
}
~~~


Tip 8: Avoid The Invoker Plugin
---
It's really slow and the output is really hard to read! If you extracted your tasks to their own class, you can create tests that run as part of the `integration-test` phase using the Maven Failsafe Plugin.

Tip 9: Create An Appender For SLF4J
---
I've used this a couple of times. If you create you own appender, [like the one I made for my plugin](https://github.com/alexec/docker-maven-plugin/blob/master/src/main/java/com/alexecollins/docker/util/MavenLogAppender.java), and add `MavenLogAppender.setLog(getLog())` to your `execute` method. You can use SLF4J for your logging. Better still, if you use a library that uses any of the common logging frameworks (Apache, Log4j etc.), then they will also log to the console.

---

I hope these tips help you to write you plugin quicker and easier!