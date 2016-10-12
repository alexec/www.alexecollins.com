---
title: "Tips for Writing Maven Plugins"
tags: maven,tips
---
I've spent a lot of time recently writing or working on plugins for Maven recently. They're simple, rewarding and fun to write. I thought I'd share a couple of tips for making life easier when writing them.

Tip 1: Separate the Task from the Mojo
---

Initially you'll put all the code for the mojo into the mojo's class (i.e. the class that extends AbstractMojo). Instead think about separating the task out and having minimal shim code for the mojo. This will:

- Make it easier to unit test.
- Mean you can easily integrate with other tools, such as Ant.
- Make it easier to convert the simple data types in the mojo so more complex types for your task (e.g. turn a String into a File).
- Separate exception translation from the task.

Tip 2: Consider Externalizing Configuration
---

Normally you configure a plugin using the <configuration/> element in the POM. This is fine for simple cases. When you have a large sets of configuration items, or where you might have several configuration profiles, this will result in long, hard to understand POMs. You can follow the assembly plugin's example,  have a standardised directory for putting config in, e.g. src/main/myplugin/config-profile-1.xml.

Tip 3: Match the Mojo to the Phase
---

Consider which phase you might want the mojo to run in. If it is doing things that ought to split accross phases, then split the mojo up and bind to the appropriate phase. It'll make it easier to test and to maintain.

Tip 4: Don't Repeat Time Consuming Work
---

Your mojo will get run multiple times on small variations of the same source code and config. Does it do a lot of intensive work every execution? I was working with a Mojo that unzipped a file every time it ran, by changing the zip code to only freshen files by checking file modification times, the task went from taking over a minute to execute to less than 10 seconds. 

Tip 5: Plan Your Testing
---

Initially you're probably writing your mojo and manually testing on the first project you're going to use it on. This will be a long testing cycle, and result in an unreliable mojo. Separating the task from the mojo makes testing the task easy, but you'll want to have some smoke tests for the mojo. Bugs in mojos can be hard for users to notice as there's a tendency to assume most mojos are well tested and reliable.

Tip 6: Consider how you Provide Documentation and Help for your Mojo
---

IDEs and Maven can be a bit unhelpful here. What does that config item mean? Can I see an example? The solution is to provide a "help" mojo and optionally a Maven site. For example, if you execute "mvn assembly:help" or "mvn surefire:help -Ddetail=true -Dgoal=test" you'll see help.

