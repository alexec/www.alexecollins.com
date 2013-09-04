---
title: "Snippet: JavaFX Maven POM"
---
<p>I could not find a good example, so here's my template.</p>

	<?xml version="1.0" encoding="UTF-8"?>
	<project xmlns="http://maven.apache.org/POM/4.0.0"
	         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
	    <modelVersion>4.0.0</modelVersion>
	
	    <groupId>com.alexecollins.javafx</groupId>
	    <artifactId>template</artifactId>
	    <version>1.0.0-SNAPSHOT</version>
	
	    <properties>
	        <javafx.version>2.1</javafx.version>
	        <javafx.home>C:\\Program Files\\Oracle\\JavaFX ${javafx.version} SDK\\rt</javafx.home>
	    </properties>
	
	    <dependencies>
	        <dependency>
	            <groupId>com.oracle</groupId>
	            <artifactId>javafx</artifactId>
	            <version>${javafx.version}</version>
	            <systemPath>${javafx.home}/lib/jfxrt.jar</systemPath>
	            <scope>system</scope>
	        </dependency>
	    </dependencies>
	
	    <build>
	        <plugins>
	            <plugin>
	                <artifactId>maven-compiler-plugin</artifactId>
	                <version>2.3.2</version>
	                <configuration>
	                    <source>1.7</source>
	                    <target>1.7</target>
	                </configuration>
	            </plugin>
	        </plugins>
	    </build>
	</project>
