---
title: Documenting XML APIs Tests
date: 2014-03-01 10:47 UTC
tags: java, junit
---
I've recently been working on an XML API that is exposed to third-parties and wonder if there's a good way to keen the documentation up to date, other that an error-prone copy and paste exercise from unit tests. 

There are two sets of information that need to be published.

1. Reference for the various XML elements and their meaning.
2. Examples of various request/responses.

There are two solutions that can be applied to existing code without too much modification:

1. Create a custom **Java doclet**. A doclet can look for classes based on interfaces and annotations, and create a custom set of documentation.
2. Have a script that produces examples.
