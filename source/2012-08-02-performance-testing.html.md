---
title: "Performance Testing"
tags: performance,testing,oped
---
<h2>Overview</h2>

<p>Performance tuning an application is time consuming, and expensive. Useful tests often needs dedicated hardware to run on, it's specialised and time consuming to prepare the ground work and write the various fixtures needed to test, and whose only perceived benefit is preventing a production issue that you don't even know will happen yet.</p>

<h2>Stero-typical Scenarios and Outcomes</h2>

<p>Here's some stereotypes I've encountered:</p>

<ul>
<li>A feature release contains a new feature that wasn't (or even could not have been) tested that has a major performance issue from the outset.</li>
<li>A change to existing code, perhaps to finesse or refine an existing feature, perhaps one that's not been requested by the customer, introduces a catastrophic performance issue.</li>
<li>A sleeper: a change in the system that only occurs after some time (e.g. running out 4-byte int for a serial column, resulting in that database table scanning for unused keys).</li>
<li>Change of use: it was designed to be used in one way, and then the customer starts using it in another way.</li>
<li>Age: the database just gets too big and queries start to time out.</li>
</ul>

<p>A common resolution to these is a herculean effort: late night and weekends with people on the phone asking "When will my site be fixed? Who's responsible for this?". I've heard this called "hero culture", and it's a development mentality that can perversely reward those who might have been expected to prevent the problem, as they are the ones capable of fixing it.</p>

<p>After resolution, a period of self-reflection. People are asking what can be done to show willingness to tackling the problem; perhaps in a one-off performance tuning exercise by a specialist, which resolves current issues. But, if the analysis is done by a seconded specialist who's not part of the team, it's an exercise whose lessons are not disseminated, and is not repeatable. Those who do not learn lessons from the past are doomed to repeat it.</p>

<p>This might be a fait-au-complet: if performance testing is more expensive than the cost of fixing periodic production issues, then this is the most logical, most cost effective approach.</p>

<p>Many system, perhaps due to cost or lack of time, have not been developed in a way that is amenable to automated testing. After all, when it's first written, you don't know if it's going to be a commercial success, so why spend money making software maintainable if it might never need to be maintained?</p>

<p>The inability to test the performance of changes can mean that improvements to the system are prevented; the cost of introducing a bug cannot be mitigated. People start to fear changes and you stagnate. A younger, faster, competitor learns from your trail-blazing and quickly writes a more modern, cheaper version of your software and starts taking your business.</p>

<h2>Resolution - Automated Performance Testing</h2>

<p>How do you fix this? How do you take a system that might even be hostile to testing, and change it so that releases become bug free and robust?</p>

<h3>Strong Foundations</h3>

<p>You should make sure your code base is reliable before you consider performance testing. Most of this is common sense.</p>

<ol>
<li>Change and test incrementally</li>
<li>Bugs first, features second; new features will only introduce new bugs, so make sure you fix any bugs first</li>
<li>Use a well developed build system</li>
<li>Be able to write and execute unit tests on your code.</li>
</ol>

<h2>Integration Test</h2>

<p>Integration test form the first part step toward full unit testing. There's many framework, depending on how users or client interface. If it is a web app, then you might use Selenium, a web service, a hand rolled SOAP client<a href="#footnote-1" style="vertical-align:super;">1</a>. Regardless, to run integration test, you'll need to be able to:</p>

<ol>
<li>Build your app</li>
<li>Deploy to a test environment</li>
<li>Execute the tests</li>
<li>Report the results.</li>
</ol>

<p>You should be able to do this at the touch of a button, otherwise you'll be the only person able to do it.</p>

<p>To do this you'll find that:</p>

<ol>
<li>You understand the architecture of your app</li>
<li>You know how to create a suitable environment for it</li>
<li>You understand the deployment scripts</li>
<li>You can deploy it automatically.</li>
</ol>

<p>These are key to automating performance testing.</p>

<h3>Performance Testing</h3>

<p>Unit testing, and to some degree integration testing, have binary outcomes: they pass and everyone's happy, they fail, and there's a bug. To a similar degree, the tools<a href="#footnote-2"/> are well supported and everyone knows how to use them.</p>

<h1>Footnotes</h1> 

<p><a name="footnote-1" style="vertical-align:super;">1</a> JUnit is a unit testing framework, its popularity has made it a common choice for integration testing, but you'll want to consider what the key differences are.</p>

<p><a name="footnote-2" style="vertical-align:super;">2</a> I'd mention that your integration and performance tests need not be written in the same language as your app. However, there are benefits of interoperability that should weigh highly in your choice.</p>
