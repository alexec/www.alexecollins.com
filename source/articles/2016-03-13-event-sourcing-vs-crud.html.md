---
title: Event Sourcing vs CRUD
date: 2016-03-13 17:00 UTC
tags: event-sourcing, crud
---
In this article, I'm going to talk about practical challenges when building a platform using **Event Sourcing**.

I've spend part of the last year developing a platform that uses Event Sourcing (ES) as a key part of state storage mechanic. Event Sourcing has been around for over a decade ([as documented by Martin Fowler](http://martinfowler.com/eaaDev/EventSourcing.html)), I found that it was easy to find articles on the benefits and the theory (including implementation in [Vaughn Vernon 's excellent DDD "Red Book"](http://www.amazon.com/Implementing-Domain-Driven-Design-Vaughn-Vernon/dp/0321834577). I didn't find as much as I hoped on the technical and architectural challenges of doing it is practice.

I'm going to assume you're familiar with CRUD, DDD, ES, and CQRS. But lets quickly re-iterate the main benefits:

- The ability to recreate historical state.
- Performance (events are typically smaller than the aggregate).
- Simplified testing (due to functional nature of events and their application to the aggregate).

IMHO, the first question you should ask before you use ES, is do I **need** historical state? You may well do, if you are doing accounting or financial transactions for examples, but the majority of domains won't need it.

ES comes with a significant complexity burden vs CRUD. This leads to potentially increased development and runtime costs.

1. You need somewhere to store your events. There aren't a great number of commercial or OSS solutions, but as you're not using your tried and tested RDMS or NoSQL solution, you'll need to take time to **evaluate those solutions**. Alternatively, you can develop an in-house solution (as we did with MongoDB).
2. You'll need to make sure that you've tested that **no side-effects occur**, e.g. you don't send another email, when you re-create the aggregate.
3. ES can be faster as you're often only doing append only operations. However, if you have an aggregate that has 100s or 1000s of events during its lifetime, to prevent problems with read operations, you'll need to be **capturing snapshots**. That means writing and testing the code.
4. If you have a type of aggregate that can have 1000s of event per aggregate, you'll need to consider your **data retention policy**. When and how will you archive data from your runtime/working set? You retention policy is probably different for each type of aggregate. You will need **a lot more disk space** than CRUD.
5. If you need to **perform any queries** on your aggregate, you won't be able to do this without re-creating it. This means that **queries will need to be written programmatically**.
6. If you need to **patch an aggregate** at runtime, e.g. to fix an issue, do you know how you'll do this?
7. As ES is a **paradigm shift**, you might want to consider the cognitive load that this might put on new developers. I'd note that it just take a bit of time for someone to understand it.
8. What happens when you **change the domain model**? Say you have a command that adds VAT, but you code assuming 20% VAT, and then the rate of VAT changes?
