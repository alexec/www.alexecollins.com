---
title: Gatling for JMeter Refugees
date: 2014-07-05 08:04 UTC
tags:
---
I've recently been looking at Gatling as an alternative to JMeter (something I've used a lot in the past) for load testing. I want to test at least 10,000 concurrent users, and I knew from using JMeter that I would need to use many more nodes than the six we had in the post.

Here are some notes I've made.

What do we want to achieve when load testing?
---

* Ensure system perform acceptable for anticipated load.
* ROI.
* Easy to write tests.
* Simple to maintain.
* Exercise concurrency issues normal tests might overlook.
* Early testing, multi environment.
* One click execution:
* Run locally, avoid clustering.
* Run on CI.
* Easy A/B testing. 
* Record results long term.

Load testing is:

1. Writing a user simulator.
1. Gathering metrics:
   1. White box.
   1. Black box.
1. Executing simulation.
1. Analysing results.
1. Making changes based on results.

DESIGN SIMULATION
---

I'm a programmer - so let me program!

No GUI - command line.

Gatling DSL much more pleasant than JMeter GUI, even for a (caveat) beginner Scala programmer. No poking around in obscure boxes.

Easy to re-ractor, extract or re-use.

Need something complex? Easy to break out into some code.

Understanding of reactive frameworks and basic functional programming make DSL easier to understand.

Oriented towards HTTP. JMS? Write your own (or search Github).

Easy to reuse, or combine scenarios.

Looks easier to write custom plugins. No GUI requirement.

Arguably easier to manage and version control. 

METRICS
---

Pretty basic compared to JMeter. Sensible defaults.

More advanced reporting a potential weak point.

Graphite integration.

Metrics are not just mean latency.

I want to see both request times, and white box metrics (e.g. query times and the like). App-Dynamics. Log files, Cacti, statsd, etc.     

EXECUTE
---

More users per node - saturate you network card. But .. evidence has been queried. Remain skeptical.

Scaling to multiple nodes not out of the box. Almost all similar tools support clustering using controller/worker model.

Debug using Charles as a proxy.

REPORTS
---

HTML reports, good for CI server, sharing. JMeter CI plugins exist.

Graphite reporting. Might be better for continuous load testing.

Primitive compared to JMeter.



