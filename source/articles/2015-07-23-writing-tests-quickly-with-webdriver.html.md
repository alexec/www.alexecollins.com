---
title: Writing Tests Quickly With WebDriver
date: 2015-07-23 08:30:00
tags: selenium, webdriver
---
A short video showing how to use `groovysh` to quickly create a WebDriver test.

<iframe width="420" height="315" src="https://www.youtube.com/embed/W-Ter-9NTLE" frameborder="0" allowfullscreen></iframe>

Here is the source code:

~~~
groovy.grape.Grape.grab(group:'org.seleniumhq.selenium', module:'selenium-firefox-driver', version:'2.45.0');
groovy.grape.Grape.grab(group:'junit', module:'junit', version:'4.12');

import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.*;

import static org.junit.Assert.*;

driver = new FirefoxDriver();

driver.get("http://localhost:8080/login.html");

driver.findElement(By.name("email")).sendKeys("alex@alex.com");
driver.findElement(By.name("password")).sendKeys("secret");
driver.findElement(By.cssSelector("input[type='submit']")).click();

assertEquals("You Are Logged In", driver.getTitle());
~~~
