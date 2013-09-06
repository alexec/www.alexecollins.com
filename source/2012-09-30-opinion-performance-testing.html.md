---
title: "Opinion: Performance Testing"
tags: testing,performance,testing
---
<h2>Overview</h2>

<p>Performance tuning an application is time consuming, and expensive. Useful tests often need dedicated hardware to run on. It's specialised and time consuming to prepare the ground work and write the various fixtures needed to run, and whose only perceived benefit is preventing a production issue that you don't even know will happen yet.</p>

<h2>Stereotypical Scenarios and Outcomes</h2>

<p>Here's some stereotypes I've encountered:</p>

* A feature release contains a new feature that wasn't (or even could not have been) tested adequately that has a major performance issue from the outset.
* A change to existing code, perhaps to finesse or refine an existing feature, perhaps a change that's not been requested by the customer, introduces a catastrophic performance issue.
* A sleeper: a change in the system that only occurs after some time (e.g. running out of values in a 4-byte integer serial column, meaning that inserts into that table require the database engine to scan for unused keys).
* Change of use: it was designed to be used in one way, and then the customer starts using it in another unanticipated way.
* Age: the database gets large and queries start to slow down, I've heard this referred to is somewhat wooly terms as "degradation".

<p>A common resolution to these stereotypes is a herculean effort: late night and weekends with people on the phone asking "When will my site be fixed? Who's responsible for this?". I've heard this called "hero culture". It's a mentality that can perversely reward those who might have been expected to prevent the problem, as they are the ones best capable of fixing it.</p>

<p>After resolution, a period of self-reflection. People are asking what can be done to show willingness to tackle the problem; perhaps in a one-off performance tuning exercise by a specialist, which resolves current issues. But, if the analysis is done by a seconded specialist who's not part of the team, it's an exercise whose lessons are not disseminated, and which is not repeatable. Those who do not learn from the past are doomed to repeat it<a href="http://en.wikiquote.org/wiki/George_Santayana">*</a>.</p>

<p>This might be a fait-accompli: if performance testing is more expensive than the cost of fixing periodic production issues, then this is the most logical, most cost-effective approach.</p> 

<p>Many systems, perhaps due to cost or lack of time, have not been developed in a way that is amenable to automated testing. After all, when a system is first written, you might not know if it's going to be a commercial success, so why spend money making system maintainable if it might never need to be maintained?</p>

<p>The inability to test the performance of changes can mean that improvements to the system are prevented; the cost of introducing a bug cannot be mitigated. People start to fear change and the product stagnates. A younger, faster, competitor learns from your success. They quickly write a more modern, cheaper version of your software and starts taking your business.</p>

<h2>Automated Performance Testing</h2>

<p>How do you implement this? How do you take a system that might even be hostile to testing, and change it so that releases become more bug free and robust?</p>

<h3>Foundations</h3>

<p>You should make sure your code base is reliable before you consider performance testing. Most of this is common sense.</p>


* Change and test incrementally.
* Bugs first, features second; new features will only introduce new bugs, so make sure you fix any bugs first.
* Use a mature developed build system.
* Be able to write and execute unit tests on your code.


<p>Once these are in place, consider using code quality tools, such as <a href="http://findbugs.sourceforge.net"FindBugs</a> or <a href="http://cobertura.sourceforge.net">Cobertura</a>, to get metrics and enforce them, failing builds that don't meet some minimum criteria.</p>

<h2>Integration Test</h2>

<p>Integration test forms the first step toward full performance testing. There's many frameworks, depending on how users or clients interface. If it is a web-app, then you might use <a href="http://seleniumhq.org">Selenium</a>, a web service, a ReST or SOAP client. Generally, a popular framework is a better choice, as it encourages adoption by the rest of your team. Ask yourself - would I rather learn something well-documented, interesting and personally valuable, or wrestle with someone else's hand-rolled vanity project? Regardless, to run integration tests, you'll need to be able to:</p>


* Build your app.
* Deploy to a test environment.
* Execute the tests.
* Report the results.


<p>Ideally, you should be able to do this at the touch of a button, otherwise you'll be the only person who does it, and you'll lose a lot of the value of your work.</p>

<p>As you do this you'll find that:</p>


* You better understand the architecture of your app.
* You know how to create a suitable environment for it.
* You understand the deployment process.
* You can deploy it automatically.


<p>These are key to automating performance testing.</p>

<h3>Performance Testing</h3>

<p>Unit testing, and to some degree integration testing, have binary outcomes: they pass and everyone's happy, they fail, and there's a bug to be fixed. To a similar degree, the tools are well supported and everyone knows how to use them. Performance testing is a bit more of an art. Ultimately a performance test produces some measures: a series of numbers, but are those numbers good or bad? Do you want to guess? A single metric, standing on it's own, can be un-enlightening, but you can look at its relative change to previous measurement. You need to (in order):</p>


* <b>Expose</b> metrics (noting that you may want to introduce new ones and deprecate old ones).
* <b>Sample</b> the metrics.
* <b>Run</b> the same test from the same baseline (e.g. by starting with a freshly provisioned server, loading it with data, and warming it up).
* <b>Report</b> on the results within a tool.


<p>Again, with a single button press.</p>

<p>If you deploy your app to one host, where do you run the tests from? What demand might they make of the office network? Do you need multiple hosts and their own LAN?</p>

<p>You'll need to expose your metrics first, and there are a few commercial and open source tools for Java, such as <a href="http://www.jinspired.com">JInspired</a> or <a href="http://metrics.codahale.com">Metrics</a>, or, indeed you can roll your own. One feature you might want is exposing the metrics over JMX, which allow sampling. <a href="http://www.opennms.org">OpenNMS</a> is a network management application that can remotely periodically sample JMX beans, and it is relatively straight forward to get graphs of those metrics. There are, of course, alternatives.</p>

<p>Now, if you automatically deploy then performance test on each commit, then you could have the details displayed on your agile wall, so the team can see when performance changes and any hot spots appear. Best of all, once it's all in place, you don't need to do much to keep it up to date.</p>
