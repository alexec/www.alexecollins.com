---
title: Java Annotation Processor Tutorial
date: 2014-11-06 23:00 UTC
tags: java, annotation processor, sprint, annotation tutorial
---
Overview
---
I've been using [Project Lombok](http://projectlombok.org), the excellent Java tool that create value-object classes with minimal code. Under the hood is using the [Java Annotation Processor](http://docs.oracle.com/javase/7/docs/api/javax/annotation/processing/Processor.html) to generate code based on reading your source code before compilation. Annotation processing a somewhat niche technique, but it has some great use cases. Lombok uses it for generate code, but another good use if for verify source code.

In a [recent tutorial](http://TODO),  we saw how Spring `@Transactional` annotation can cause problems. We'll write an annotation processor to identify these prevent these problems at compile time.