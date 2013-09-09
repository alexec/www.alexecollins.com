---
title: The Alex Test
date: 2013-09-09 10:33 UTC
tags: oped
---
I've been reading [Joel on Software's back catalogue](http://www.joelonsoftware.com), and he's well know of [The Joel Test](http://www.joelonsoftware.com/articles/fog0000000043.html). I thought I'd write some additional tests for agile web developers. Naturally I've called it "The Alex Test".

1. Do you use distributed version control? Why isn't SVN up to the task anymore? Simply because you can more commits, faster with DVCS meaning you're productive.
1. Can you build and deploy to test with one step? You can build in one step. Fine. Can you get your software somewhere it can be tested just as easily? 
1. Can you go from commit to production deploy in less than 30 minutes, including tests? If you can't, can you get fixes into production in a similar time?
1. So you make builds after each commit and keep metrics on your build? Doing a build on every commit means that you'll be able to track the origin of a failing. Keeping metrics means you'll be able to spot when a build starts to take longer, or help identify twitchy tests.
1. Do you have a bug database? Does someone own the triaging of bugs? Does the person who wrote it, fix it?
1. Do you have daily standups where the whole team attends, and an active product owner?
1. Do you have quiet working conditions? Are they relaxed and flexible? Does the team look forward to coming to work?
1. Do you have access to the tools you want? Do you have to beg for a virtual machine to run a tools on? Do you have the flexibility to choose your system? Do you ever have to hot desk?
1. Do you use TDD and/or BDD? Do you have team members who focus on automated quality assurance? Do you have testers with a good understanding of the problems you're trying to solve.

