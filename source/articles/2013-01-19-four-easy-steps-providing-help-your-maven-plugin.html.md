---
title: "Four Easy Steps to Providing Help for your Maven Plugin"
tags: maven
---
<p>This is easy, it is supported out of the box.</p>

<p>Step 1 - make sure each mojo has the JavaDoc, this will be used to generate your help files. E.g.:</p>

~~~java
	/**
	 * Create and provision each of the boxes defined in src/main/vbox.
	 *
	 * @goal provision
	 * @phase pre-integration-test
	 */
	public class ProvisionMojo extends AbstractVBoxesMojo {
	
		/**
		 * Which targets in the Provision.xml to execute, or all if "*".
		 *
		 * @parameter expression="${vbox.provision.targets}", default="*"
		 */
		protected String targets = "*";
~~~

<p>Step 2 - add the "helpmojo" goal to your plugin.</p>

~~~xml
	            <plugin>
	                <groupId>org.apache.maven.plugins</groupId>
	                <artifactId>maven-plugin-plugin</artifactId>
	                <version>3.2</version>
	                <executions>
	                    <execution>
	                        <id>generated-helpmojo</id>
	                        <goals>
	                            <goal>helpmojo</goal>
	                        </goals>
	                    </execution>
	                </executions>
	            </plugin>
~~~
<p>Step 3 - execute "mvn install".</p>
<p>Step 4 - test by executing "mvn vbox:help" (substitute your own plugin's name), you'll see something like this.</p>

~~~
...

A Maven plugin for creating, starting, and stopping VirtualBoxes.

This plugin has 8 goals:

...

vbox:help
  Display help information on vbox-maven-plugin.
  Call mvn vbox:help -Ddetail=true -Dgoal=<goal-name> to display parameter
  details.

...

vbox:provision
  Create and provision each of the boxes defined.
...
~~~

<p>An example of the usage can be <a href="https://github.com/alexec/maven-vbox-plugin/tree/master/vbox-maven-plugin">found on GitHub</a>. And I've written <a href="/tips-writing-maven-plugins">tips on writing Maven plugins before</a>.</p>
