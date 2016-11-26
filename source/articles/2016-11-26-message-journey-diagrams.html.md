---
title: Message Journey Diagrams
date: 2016-11-26 17:28 UTC
tags: uml, architecture
---
I've developed a new diagram that I think it much better at communicating how the messages in a system flow between components. I've used **sequence diagrams** for this in the past, but I've always found a number of problems with them.

* They have a complex syntax that many people, especially non-technical people, don't understand.
* They take time to write.
* If there are more that a couple of participants, then they get very large.
* If you need to make a small change, you often have to re-write the entire diagram - not whiteboard friendly.

This very simple flow produces a large diagram:

![Sequence Diagram](/images/message-journey-diagrams/sequence-diagram-example.png)

What's wrong with this?

* The end of the flow, and the outputs, is far away from the start and the inputs.
* If I want to add a participant early in the diagram, the whole thing changes.
* I need to know and understand the `alt` syntax.
* The line between the Website and the Audit Log is really long.

I've set out to create a new type of diagram to replace sequence diagrams:

I decided to **focus on the process** rather than the participant, use a small number of **familiar symbols** (anything else, such as conditional or loops are done using notes), and keep the **syntax terse**.

The rules are basic:

* Arrows show the flow of messages; they are always clockwise
* There are only actors, processes, and databases.
* A process is not a service, it can appear more than once (this maybe confusing the first time you see this)
* Everything else is a note

![Message Journey Diagram](/images/message-journey-diagrams/message-journey-diagram-example.png)

I'd love to get your feedback - please add your comments below.
