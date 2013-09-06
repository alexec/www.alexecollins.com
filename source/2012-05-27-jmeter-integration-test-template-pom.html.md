---
title: "JMeter Integration Test Template POM"
tags: jmeter,testing,performance
---
<p>Here's the basic layout for a JMeter performance test using Cargo and Tomcat.</p>
	<?xml version="1.0" encoding="UTF-8"?>
	<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
	    <modelVersion>4.0.0</modelVersion>
	
	    <groupId>com.alexecollins</groupId>
	    <artifactId>jmeter-parent</artifactId>
	    <version>0.0.1-SNAPSHOT</version>
	
	    <url>/</url>
	
	    <dependencies>
	    </dependencies>
	
	    <build>
	        <plugins>
	            <plugin>
	                <artifactId>maven-antrun-plugin</artifactId>
	                <executions>
	                    <execution>
	                        <id>default</id>
	                        <phase>clean</phase>
	                        <goals>
	                            <goal>run</goal>
	                        </goals>
	                    </execution>
	                </executions>
	                <configuration>
	                    <tasks>
	                        <!-- delete some files to ensure that test run from the same base-line -->
	                        <delete includeemptydirs="true">
	                            <fileset dir="${project.basedir}">
	                                <include name="**/jmeter.log"/>
	                            </fileset>
	                        </delete>
	                    </tasks>
	                </configuration>
	            </plugin>
	            <plugin>
	                <groupId>org.codehaus.cargo</groupId>
	                <artifactId>cargo-maven2-plugin</artifactId>
	                <version>1.2.0</version>
	                <executions>
	                    <!-- start AND deploy the war for this project,
	                        war details need to be configured below too -->
	                    <execution>
	                        <id>start-container</id>
	                        <phase>pre-integration-test</phase>
	                        <goals>
	                            <goal>start</goal>
	                            <goal>deploy</goal>
	                        </goals>
	                    </execution>
	                    <execution>
	                        <id>stop-container</id>
	                        <phase>post-integration-test</phase>
	                        <goals>
	                            <goal>stop</goal>
	                        </goals>
	                    </execution>
	                </executions>
	                <configuration>
	                    <container>
	                        <type>installed</type>
	                        <containerId>tomcat6x</containerId>
	                        <zipUrlInstaller>
	                            <url>http://archive.apache.org/dist/tomcat/tomcat-6/v6.0.32/bin/apache-tomcat-6.0.32.zip</url>
	                        </zipUrlInstaller>
	                        <dependencies>
	                            <!-- add data-source dependencies here-->
	                        </dependencies>
	                    </container>
	                    <configuration>
	                        <files>
	                            <copy>
	                                <!-- copy in our a server.xml file (originally taken from executing "mvn cargo:run")
	                                     with added resource into Tomcat's conf dir -->
	                                <file>src/test/conf/server.xml</file>
	                                <todir>conf</todir>
	                            </copy>
	                        </files>
	                        <properties>
	                            <cargo.logging>medium</cargo.logging>
	                        </properties>
	                    </configuration
	                    <deployer>
	                        <deployables>
	                            <deployable>
	                                <!-- a page to ensure that the app is up and running before the
	                                     load testing starts -->
	                                <pingURL>http://localhost:8080/${project.build.finalName}/</pingURL>
	                                <pingTimeout>300000</pingTimeout>
	                            </deployable>
	                        </deployables>
	                    </deployer>
	                    </configuration>
	            </plugin>
	            <plugin>
	                <groupId>com.lazerycode.jmeter</groupId>
	                <artifactId>jmeter-maven-plugin</artifactId>
	                <version>1.4</version>
	                <executions>
	                    <execution>
	                        <id>jmeter-tests</id>
	                        <phase>integration-test</phase>
	                        <goals>
	                            <goal>jmeter</goal>
	                        </goals>
	                    </execution>
	                </executions>
	            </plugin>
	        </plugins>
	    </build>
	</project>
