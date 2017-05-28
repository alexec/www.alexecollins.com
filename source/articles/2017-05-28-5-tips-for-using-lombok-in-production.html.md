---
title: 5 Tips For Using Lombok In Production
date: 2017-05-28 18:28 UTC
tags: java, lombok
---
I was reminded the other day about the excellent [Project Lombok](https://projectlombok.org). If you're not familiar with this tool, it helps reduce boilerplate AND testing. You annotate your Java source code with some special annotations, and it generates code based for you. For example, if you annotate a field with `@Getter` it generates a public getter method for that field.

Having previously used it successfully on a number of production systems, here's my top 5 tips:

**Tip 1: No Lombok with logic**

Bytecode complied for generated code in hard to debug. This is made more confusing where generated code gets mixed with logic. Lombok works well if you don't mix the it with logic.

A useful side effect of this tip is that classes only contain generated code.

**Tip 2: Don't test the generated code**

The generated code is trustworthy, so you can save a lot of time by neither testing it, nor performing static analysis on it.

If a class only contains fields, then you don't need to test it or perform static analysis on it.

**Tip 3: Use `@Data` for your DAOs**

Where Lombok especially useful then? In **DAOs**. These objects typically don't have a lot of logic and a great deal of boilerplate. Specifically three annotations were the most useful.

`@Data` creates your getters, setters, to string and equals/hash code. Great for DAOs in either the database layer, or in the API layer.

**Tip 4: Use `@Value` for immutable value-objects**

`@Value` is essentially an immutable version of `@Data`. Very useful for immutable value-objects. Use in many of the cases you might use a Scala case class.

**Tip 5: Use `@Builder`**

`@Builder` is useful when you have an object with many fields with the same type. Rather than having a constructor with many string fields, use the builder instead.

**Tip 6: Think about avoiding the other annotations**

There are a number of annotations that we never found widely useful:

* `val` - A great idea, but hobbled by poor IDE support.
* `@Cleanup` - Use try-with-resources.
* `@SneakyThrows` - Throw only runtime exceptions, and perform exception mapping where needed.
* `@Syncronized` - Just never found a place to use this.

**Tip 7: Exclude generated classes from Sonar report**

As the generated code typically ends up with many un-tested methods (e.g. you never test the generated `equals` as you don't need to, but they tend to end up being very complex for classes with many fields). These classes are excluded for static analysis and code coverage. If you are using Maven and Sonar, you can do this using the `sonar.exclusions` property.

I hope you found these tips useful! Please leave a comment if you did!!
