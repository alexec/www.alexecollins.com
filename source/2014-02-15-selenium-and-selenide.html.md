---
title: Selenium and Selenide (vs Geb)
date: 2014-02-15 17:49 UTC
tags: selenium, testing, java
---
It my quest to find a good JVM system for writing Selenium test, I've previously [posted on Geb](/geb-selenium-cucumber-maven-tutorial/), and liked it a lot, but there were one or two rough edges. I've found another framework: [Selenide](http://selenide.org).

I've updated the [source code to use Selenide](https://github.com/alexec/geb-maven-tutorial/tree/selenide) rather than Geb.

Quick Comparison chart:

|          | **Geb**                 | **Selenide** |
| Website  | [http://www.gebish.org](http://www.gebish.org) | [http://selenide.org](http://selenide.org) |
| Version  | 0.93                    |  2.7 |
| Docs     | Lots, patchy            | Terse | 
| Language | Groovy                  | Java | 
| LOC      | 77                      | 37   | 

I like Selenium, and could consider it for a commercial project. Not something I could quite do with Geb yet.