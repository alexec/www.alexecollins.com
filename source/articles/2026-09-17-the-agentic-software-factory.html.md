---
title: The Agentic Software Factory
date: 2026-09-17 09:00 UTC
tags: ai, architecture, software
published: true
---
<p class="lede">I have spent two years building agentic software factories, and for most of the first one I could not have told you what I was building. It started as a way to stop repeating myself. It became the thing that takes work in at one end and puts shipped software out at the other, with agents doing the execution.</p>

Something like it is being built in a lot of companies right now, under a lot of different names. Platform teams are wiring coding agents into CI. Vendors are shipping control planes. Somebody in every large engineering organization has a diagram with boxes labeled "orchestrator" on it. All of those are attempts at the same object, and the object deserves a name and a description.

So I am going to walk down the stack, top to bottom, and say for each layer what it is made of and why it has to be there. Not a build guide. Not an argument that you should build one, because you will build one or buy one either way, and by the time the decision reaches you the interesting question is what is inside. What I can offer is the parts list, and the places where my first answer was wrong.

<div class="toc">
<p class="toc-note">Fourteen sections, about a sixty minute read.</p>
<ol>
<li><a href="#what">What is an agentic software factory?</a></li>
<li><a href="#why">Why this is coming</a></li>
<li><a href="#interface">Layer 6, the interface</a></li>
<li><a href="#inversion">The interface inversion</a></li>
<li><a href="#work-orders">Projects and work orders</a></li>
<li><a href="#agents">Layer 5, agents</a></li>
<li><a href="#runtime">Layer 4, runtime</a></li>
<li><a href="#routing">Layer 3, routing and gateways</a></li>
<li><a href="#connectors">Layer 2, connectors</a></li>
<li><a href="#data">Layer 1, data and sandbox</a></li>
<li><a href="#self">The factory builds itself</a></li>
<li><a href="#protocols">Open protocols and lock-in</a></li>
<li><a href="#unsolved">Two unsolved problems</a></li>
<li><a href="#close">The agents are the least interesting part</a></li>
</ol>
</div>

## What is an agentic software factory? {#what}

<div class="key">
<p>An agentic software factory is a system that takes in specifications and produces working software, where AI agents do the execution and people decide what to build.</p>
</div>

Every clause in that sentence is load-bearing, so take them one at a time.

**Takes in specifications.** Not tickets, not prompts, not a Slack message that says "can you make the login page less ugly". A specification is a written statement of what the software should do, complete enough that somebody who was not in the room can act on it. Product requirements, a technical design, an implementation plan, an acceptance criterion, a bug report with steps to reproduce. All of those count. What they have in common is that they are durable, they are readable by a person and by a model, and they exist before the work starts. A factory that takes in vibes produces software that matches the vibes.

**Produces working software.** Working means it compiles, the tests pass, it is merged, and it is running somewhere a user can reach. A pull request sitting open is not the output. A branch that has not landed is not the output. Drawing the boundary at "running in production" is what makes the thing a factory rather than a code generator, because it forces the whole downstream path into scope: review, integration, verification, release. Those were always the expensive parts, and a system that stops at the diff has not touched any of them.

**AI agents do the execution.** Execution is the reading, writing, running, debugging, and re-running. An agent picks up a work order, opens the repository, figures out where the change goes, makes it, runs the tests, fixes what it broke, and raises a change for review. Nobody types the code. That is the part that changed in the last two years, and it changed fast enough that most architecture written before it is now aimed at the wrong bottleneck.

**People decide what to build.** Somebody has to say that this feature matters more than that one, that the API should be shaped this way, that the migration happens before the rewrite and not after. Judgment about what is worth doing stays with people, and I do not expect that to move soon, because it is mostly a question about a business rather than a question about code.

Four clauses, and notice the one that is missing. Nothing in the definition says a person checks the work. That omission is deliberate and it is the part people argue with, so it gets its own section before we go any further.

### Who checks?

Instinct says a person signs off. Somebody reads the change set, decides it does what the work order asked, and approves it. That instinct is worth examining, because it is a sizing assumption wearing the clothes of a safety one.

Work the arithmetic again. Four hundred changes a week, eight engineers. Put a person on every change and you have rebuilt the bottleneck the factory exists to remove. Put a person on the agent's review instead of on the change and you have moved the queue one step back, which buys a little and not much. Sample one change in twenty and you are running a quality process, not a gate, and honesty requires admitting the other nineteen shipped unchecked.

So take it to the end. Changes can ship to production with no person in the loop at all, and that includes verification. Not as a failure of governance. As the design.

What replaces the person is not trust. It is evidence, produced by the system, about this specific change.

**The specification becomes executable.** Acceptance criteria written as prose are a thing somebody has to interpret. Written as tests they are a thing the factory can check. Which puts real weight on the specification, because a work order whose definition of done is "the retry works properly" cannot be verified by anything, human or otherwise. One whose definition of done is a set of cases with expected results can be.

**The agent writes tests and runs them,** and the tests are part of the artifact rather than a side effect of it. A change set with no new tests, against a work order that changed behavior, is a change set that failed verification. The factory can say so without anybody reading the diff.

**Mechanical checks run every time,** all of them, because they are cheap and machines are good at them. Type checking, static analysis, dependency and license scanning, secret detection, performance regression against a baseline. None of that is new. What is new is that it stops being advisory.

**Policy runs as code.** Does this change touch a payment path? Does it alter a public API? Does it read a column marked as personal data? Questions like those have deterministic answers, and the answers can gate a merge. Somebody writes the rules once, deliberately, and they apply to every change without a meeting.

**Production finishes the job.** Ship to a small slice of traffic, watch the error rate and the latency and the business metric the change was supposed to move, roll back automatically when they go the wrong way. Verification stops being something that happens before release and becomes something release does. Progressive delivery was invented for human-authored changes and it is worth more here, because the volume is higher and a rollback is the cheapest check in the system.

#### The real gate is reversibility

None of that makes people unnecessary everywhere. It relocates them, and what decides where is not how important a change feels. It is how expensive it is to be wrong.

Reversible changes can ship with nobody near them. A bad deploy gets rolled back in ninety seconds, the canary caught it before most users saw it, and the cost of the mistake is a revert and a line in the trace. Spending a person's afternoon reasoning about that case ahead of time is a poor trade.

Irreversible changes are different, and the list is shorter than people expect. Rewriting a published history. Deleting data or a record. Moving money. Sending a message to everybody. Changing a public API contract other companies already build against. Anything a customer sees once and cannot unsee. Each has the same property. Rollback does not restore the world, so evidence gathered afterward arrives too late to be worth anything.

Splitting a job at that seam is the part worth copying, because most jobs have one. Making a repository private is reversible and an agent can do it. Purging its history is not and should not. Same afternoon, same repository, and the line falls through the middle of the task rather than around it.

Write the list down deliberately. The failure mode is not that somebody ships an irreversible change by accident. It is that the irreversible set quietly becomes whatever nobody got around to automating, which tracks effort instead of harm.

#### The dial goes to zero

Human checking is therefore a policy per class of change, not a property of the architecture. Set it high at first, with a person on everything, because you have no evidence yet and no calibration. Lower it as evidence accumulates, one class of change at a time, with the revert rate and the incident rate telling you whether you moved too fast.

Moving an item off that list is a real decision and it deserves to be treated like one. The thing I would insist on is not the decision itself but where it gets recorded. Write the widened permission into the document the agents actually read, with the date and the words it was granted in. A permission that lives in somebody's memory of a conversation is not a permission, and it will be relitigated by the next agent that hits it.

Build the factory so the dial can reach zero, even if you never take it there. A system that assumes a person will be present carries that assumption everywhere: in the states a work order can occupy, in the events the router listens for, in the metrics, in the interface. Retrofitting autonomy into it later is a rewrite. Building for zero and then choosing to keep a person in the loop costs nothing.

One honest limit, and it is the reason the other half of the definition survives untouched. Everything above verifies that a change does what the specification says and does no visible harm. None of it verifies that the specification was right. People are what you have for that, which is why they decide what to build.

### The physical shape

Definitions are slippery, so it helps to have a picture of the building. An agentic software factory has four parts you could walk around.

A **front door**, which is work management, organized by project. Work arrives here and gets written down. Everything the factory does traces back to a line in this system, and everything the factory finishes is reported back into it. Without a front door you have a pile of agents and no way to say what they are doing or whether they finished.

A **floor**, where the agents work. Each agent has a sandbox: a machine, or something that behaves like one, with a checkout of the code, a shell, a network connection, and permission to break things. Several agents work at once, on different parts of the same project or on different projects. The floor is where the actual labor happens and it is the part that looks most like a factory, because it is a room full of workers with identical equipment doing non-identical work.

A **conveyor belt**, which moves work between stations. An agent finishes a change and raises a pull request. That event has to reach a reviewer. The reviewer requests changes, and that event has to get back to whoever made the change. A nightly timer fires and that has to become work. Movement between stations is event-driven, and it is the difference between a factory and a room where everybody shouts.

**Plumbing**, underneath all of it: compute, network, storage. Unglamorous, and the thing that decides whether you can run three agents or three hundred. Give agents a way to ask whether there is capacity before they start something expensive. Elastic infrastructure hides the question rather than answering it, and the bill arrives either way.

<figure>
<svg class="diagram" viewBox="0 0 720 400" role="img" aria-labelledby="fig-shape-title">
  <title id="fig-shape-title">The physical shape of a factory: a front door, a floor of agent stations, a conveyor belt between them, and plumbing underneath</title>
  <rect class="surface" x="14" y="36" width="692" height="248" rx="6"/>

  <rect class="box box-alt" x="30" y="60" width="132" height="200" rx="4"/>
  <text class="t-md bold t-mid" x="96" y="88">Front door</text>
  <text class="t-sm t-mute t-mid" x="96" y="112">Work management,</text>
  <text class="t-sm t-mute t-mid" x="96" y="128">by project</text>
  <rect class="box" x="52" y="150" width="88" height="20" rx="3"/>
  <text class="t-sm t-mid" x="96" y="164">Work order</text>
  <rect class="box" x="52" y="178" width="88" height="20" rx="3"/>
  <text class="t-sm t-mid" x="96" y="192">Work order</text>
  <rect class="box" x="52" y="206" width="88" height="20" rx="3"/>
  <text class="t-sm t-mid" x="96" y="220">Work order</text>

  <text class="t-sm t-mute" x="186" y="56">The floor</text>
  <rect class="box box-warm" x="186" y="66" width="150" height="82" rx="4"/>
  <text class="t-md bold t-mid" x="261" y="94">Coding agent</text>
  <text class="t-sm t-mute t-mid" x="261" y="114">sandbox, checkout,</text>
  <text class="t-sm t-mute t-mid" x="261" y="130">shell, network</text>

  <rect class="box box-warm" x="352" y="66" width="150" height="82" rx="4"/>
  <text class="t-md bold t-mid" x="427" y="94">Review agent</text>
  <text class="t-sm t-mute t-mid" x="427" y="114">sandbox, checkout,</text>
  <text class="t-sm t-mute t-mid" x="427" y="130">shell, network</text>

  <rect class="box box-warm" x="518" y="66" width="150" height="82" rx="4"/>
  <text class="t-md bold t-mid" x="593" y="94">Release agent</text>
  <text class="t-sm t-mute t-mid" x="593" y="114">sandbox, checkout,</text>
  <text class="t-sm t-mute t-mid" x="593" y="130">shell, network</text>

  <rect class="box box-dim" x="186" y="182" width="482" height="56" rx="4"/>
  <text class="t-md bold" x="202" y="204">Conveyor belt</text>
  <text class="t-sm t-mute" x="202" y="224">Event-driven routing between stations</text>

  <path class="line accent" d="M261 148 L261 182"/>
  <path class="line accent" d="M427 182 L427 148"/>
  <path class="line accent" d="M593 148 L593 182"/>
  <path class="accent-fill" d="M261 182 l-4 -8 l8 0 z"/>
  <path class="accent-fill" d="M427 148 l-4 8 l8 0 z"/>
  <path class="accent-fill" d="M593 182 l-4 -8 l8 0 z"/>
  <path class="line accent" d="M162 160 L186 160"/>
  <path class="accent-fill" d="M186 160 l-8 -4 l0 8 z"/>

  <rect class="box box-dim" x="14" y="304" width="692" height="66" rx="6"/>
  <text class="t-md bold" x="34" y="330">Plumbing</text>
  <text class="t-sm t-mute" x="34" y="352">Compute, network, storage</text>
  <path class="line-dash" d="M96 284 L96 304 M261 284 L261 304 M427 284 L427 304 M593 284 L593 304"/>
</svg>
<figcaption>Four parts you could walk around. Work enters through the front door, gets picked up on the floor, and moves between stations on the belt. None of it runs without the plumbing.</figcaption>
</figure>

### The six layers

Walking around the building gives you the shape. Building one gives you a stack, and the stack is what the rest of this post walks down. Six layers, starting at the one a person actually stands at.

<figure>
<svg class="diagram" viewBox="0 0 720 470" role="img" aria-labelledby="fig-stack-title">
  <title id="fig-stack-title">The six layers of an agentic software factory, from the interface at the top to data and sandboxes at the bottom, over compute, network and storage</title>

  <text class="t-sm t-mute t-end" x="46" y="52">6</text>
  <rect class="box box-alt" x="60" y="20" width="644" height="56" rx="4"/>
  <text class="t-lg" x="78" y="44">Interface</text>
  <text class="t-sm t-mute" x="78" y="63">Escalation queue, work by project, artifacts, chat</text>

  <text class="t-sm t-mute t-end" x="46" y="118">5</text>
  <rect class="box" x="60" y="86" width="644" height="56" rx="4"/>
  <text class="t-lg" x="78" y="110">Agents</text>
  <text class="t-sm t-mute" x="78" y="129">Roles, prompts, tools, skills, memory</text>

  <text class="t-sm t-mute t-end" x="46" y="184">4</text>
  <rect class="box" x="60" y="152" width="644" height="56" rx="4"/>
  <text class="t-lg" x="78" y="176">Runtime</text>
  <text class="t-sm t-mute" x="78" y="195">Sessions, harness, models, evals</text>

  <text class="t-sm t-mute t-end" x="46" y="250">3</text>
  <rect class="box" x="60" y="218" width="644" height="56" rx="4"/>
  <text class="t-lg" x="78" y="242">Routing and gateways</text>
  <text class="t-sm t-mute" x="78" y="261">Agent router, workflow database, MCP gateway, API gateway</text>

  <text class="t-sm t-mute t-end" x="46" y="316">2</text>
  <rect class="box" x="60" y="284" width="644" height="56" rx="4"/>
  <text class="t-lg" x="78" y="308">Connectors</text>
  <text class="t-sm t-mute" x="78" y="327">Version control, work tracking, messaging, documents, memory</text>

  <text class="t-sm t-mute t-end" x="46" y="382">1</text>
  <rect class="box" x="60" y="350" width="644" height="56" rx="4"/>
  <text class="t-lg" x="78" y="374">Data and sandbox</text>
  <text class="t-sm t-mute" x="78" y="393">Registries, workspaces, sandboxes, identity, tracing</text>

  <rect class="box box-dim" x="60" y="420" width="644" height="40" rx="4"/>
  <text class="t-md t-mid" x="382" y="445">Compute, network, storage</text>
</svg>
<figcaption>Six layers. The post walks down them in order, because that is the order a person meets them.</figcaption>
</figure>

Layer 6 is where a person stands: a queue of questions to answer, work grouped by project, and the artifacts the agents produced. Layer 5 is the agents, which are roles with prompts and tools. Layer 4 is the runtime that holds a session open, calls a model, and runs what the model asks for. Layer 3 routes events to agents and governs the tools those agents can reach. Layer 2 connects the factory to the systems your company already runs. Layer 1 is the registries, the workspaces, the sandboxes, and the record of what happened.

### The thesis, which follows from the definition

Read the definition again and notice what it does not mention. It says nothing about how many agents there are, how they talk to each other, which model they use, or whose product they came from. It talks about specifications going in and software coming out, and about who decides and who checks.

That omission is the whole argument. Most people frame this problem as orchestrating agents. It is really about managing work. The interesting object in the system is the work order, not the agent.

Agents are interchangeable. Swap the model underneath one and it is still the same agent doing the same job, a little better or a little worse. Run three of them or thirty. Mix vendors, put one company's model on the coding station and another's on the review station. None of that changes the work order that went in or the artifact that came out. The work order is the durable object: it has an identity, a history, a state, a specification attached to it, and a person who cares about it. Sessions are disposable. Agents are disposable. Models get replaced roughly every six months and you will not mourn any of them.

Once you see it that way, a lot of architectural questions answer themselves, and a lot of popular ones stop being interesting. How do agents negotiate with each other? Mostly they should not. How do you chain them into graphs? Mostly you should not. What you need is a system that knows what work exists, what state each piece is in, who or what is on it, what it produced, and which questions are blocking it. That is a work management system with agents attached, and it is a much older and better understood problem than anything in the agent literature.

## Why this is coming {#why}

Ask an engineering leader what slows their organization down and almost nobody says typing. They say the pull request that sat for four days. They say the integration branch that went red on Tuesday and stayed red until Friday. They say the release train that only leaves on Thursdays, the staging environment that three teams are fighting over, the flaky test suite everybody reruns twice before believing.

Writing code was never the constraint. Getting code reviewed, integrated, verified, and released was the constraint, and it has been for twenty years. Every methodology of the last two decades has been an attack on that downstream stretch. Continuous integration exists because integrating late is worse than integrating often. Trunk-based development exists because long-lived branches diverge. Feature flags exist so that release can be decoupled from merge. Pull request review exists because the cost of a defect rises the further it travels. Every one of those is a downstream fix.

Agents did something specific to that picture. They made the upstream stretch close to free, and they left the downstream stretch exactly where it was.

Consider what that does to the arithmetic. A team of eight engineers used to produce maybe forty pull requests a week, and the review, integration, and release machinery was sized for forty. Give the same eight engineers agents and they can produce four hundred. Nothing about the review machinery changed. Nothing about the integration machinery changed. The test suite still takes eighteen minutes and still flakes one run in twelve. So the queue grows, and the thing everybody feels is that the agents made them slower, which is not true and is also exactly what it feels like.

Anyone who has run a physical production line recognizes this immediately. Speed up one station and you do not speed up the line. You move the bottleneck and you build up inventory in front of it. Work in progress piles higher, cycle time goes up, and everything downstream of the new bottleneck starves while everything upstream floods. Software teams are discovering this the hard way right now, one over-productive coding assistant at a time.

<div class="key">
<p>A factory is what you build when you accept that the whole line has to be re-sized, not just the station that got faster.</p>
</div>

### What re-sizing actually means

Four hundred changes a week cannot be reviewed by eight people reading diffs. So an agent reviews, and the evidence it produces is what the merge gates on. Four hundred changes a week cannot land on one trunk by hand, so merging becomes automatic, gated on evidence rather than on somebody clicking a green button. Verification cannot be a person clicking through a staging environment, so it becomes tests an agent wrote and ran, mechanical checks that block on failure, and a canary that rolls itself back. Release cannot be a Thursday ritual, so it becomes continuous and reversible.

Each of those is a known technique. None of them is new. What is new is that they stop being nice-to-haves that mature organizations get around to, and become the load-bearing walls of the system. You cannot run agents at volume without them, in the way you cannot run a dishwasher without plumbing.

And once you have built all of that, look at what you have: a work intake system, a pool of workers, event-driven routing between stations, automated verification, automated release, and a small number of humans deciding what is worth building. You have built a factory. You may not have set out to build one. The requirements force the shape.

### Why the model keeps getting better is part of the argument

I am going to state an assumption rather than defend it at length, because defending it would take another post and because the post you are reading does not depend much on the size of the effect. AI progress continues roughly on its current path. Agents went from unable to complete a two-file refactor to able to carry a multi-day piece of work in about two years. I expect the next two years to move a similar distance.

What matters architecturally is not how good the model gets. It is that *the model is a component you swap out*. That single property drives almost every design decision later in this post. If the model is a component, then the factory has to be built so that replacing it is a configuration change rather than a rewrite. It means you do not build clever scaffolding to work around the current model's weaknesses, because the scaffolding will outlive the weakness and then you are maintaining a workaround for a problem that no longer exists. It means your evaluation story has to be able to answer "is the new model better at our work" on demand.

Plenty of the agent tooling written in 2024 was really a set of prosthetics for models that could not hold a plan in their head. Most of that tooling is now dead weight. Build for the swap, not for today's limitations.

### Build or buy, and nothing else

Three options exist in principle. Ignore it, build one, or buy one.

Ignoring it is not an option for anyone whose competitors are not ignoring it, which is a polite way of saying it is not an option. So you are choosing between building and buying, and the honest answer is that most organizations will do both: buy the runtime, buy the models, and build the parts that touch their own systems, because nobody sells a connector to your internal deployment tool.

Which is exactly why the interesting question is what is inside. If you buy, you are choosing between products whose differences are architectural, and you need to be able to see those differences. If you build, you need a parts list. Either way the useful thing to know is the anatomy, so the rest of this post is the anatomy, from the top of the stack down.

## Layer 6, the interface {#interface}

Start on a Monday morning, because that is when the design of this layer gets tested.

Your factory ran all weekend. Nobody was watching it. Over roughly sixty hours it picked up thirty-one work orders across four projects, finished nineteen of them, raised twenty-six pull requests, merged twenty-two, and got stuck eleven times. You open the interface with a coffee in your hand, and what you see first decides whether this system is useful or whether it is a very expensive way to generate homework.

What you should see first is the queue of questions.

### Escalations

An escalation is a question an agent cannot answer for itself. Not a status update, not a summary, not a request for praise. A question, with options, that blocks a piece of work until somebody answers it.

Real ones from a real weekend look like this. An agent is implementing a payment retry and the specification does not say what happens when the retry succeeds after the customer has already been emailed about the failure. It cannot invent the policy, so it asks. An agent needs to check a vendor dashboard and hits a login page with a one-time code going to somebody's phone. It cannot log in, so it asks. An agent is told to follow the deployment runbook and cannot find a deployment runbook, having searched the wiki, the repository, and the Slack channel where such things are usually posted. It asks where the document lives. An agent has made a change that touches a file with three owners and no clear convention, and rather than pick one it asks which convention wins.

Those four have nothing in common technically. They have everything in common operationally: each one is a place where the work stopped, the agent correctly declined to guess, and a human answer of one or two sentences unblocks hours of machine work. Escalations pay back more than anything else in the interface, which is why they go at the top.

An escalation needs a small number of parts to be useful. It needs the question in one line. It needs enough context that you can answer without opening anything else. It needs options, because "what should I do?" is a much worse question than "A or B, and I would pick A because of this". It needs to name the work it is blocking, so the system can unblock that work by itself when the answer lands. And it has to reach you wherever you are, not sit in a web page you might open on Tuesday.

Options and a recommendation were not my first design. My first design let an agent ask an open question, and open questions arrived as a pile of things to think about instead of a pile of things to answer. Turning each one into two or three options with a recommendation turned a decision into a tap.

Two more rules, both of which I learned by getting them wrong. One question per escalation, because two questions in one message is something the reader has to think about rather than answer. And raise it the moment the work stops, not at the end of the run. An agent that saves up its questions has already spent the time the escalation was supposed to save.

Blocking has to be automatic in both directions. A work order gets blocked against the escalation's id, and it unblocks itself the moment the answer lands. A work order left merely blocked on a person, with no question behind it, pushes the sorting back onto the person that raising it properly would have done for them.

That last point is worth dwelling on for a second. An agent that asks a question into its own log has not asked anybody anything. The question has to leave the agent's context and enter yours, by whatever route you actually read: a notification, an email, a message in a channel you have open. Half of the value of a factory is that it can run while you are asleep. All of that value evaporates if the questions it accumulates overnight only surface when you happen to look.

### Escalation rate is a two-sided metric

One number belongs on the wall. Escalations per completed work order, tracked per agent role and per project, watched in both directions.

Too high and the agent is useless. An agent that asks four questions per work order has not saved anybody any time, it has converted machine work into human work at an unfavorable exchange rate. You had one job, which was to not need me. Common causes are a specification too thin to act on, a tool the agent lacks so it keeps asking a person to do something for it, and a prompt so cautious that the agent asks permission to breathe.

Too low and something worse is happening. An agent that never asks is not necessarily confident and correct. It may be plowing ahead through exactly the ambiguities that should have stopped it, inventing a retry policy, picking a convention at random, guessing at a number. You will find out three weeks later when somebody reads the code. A zero escalation rate on a project with a thin specification is a red flag, not a green one.

My best trick for lowering the rate is not a better prompt. It is noticing how often a question already has an answer written down somewhere. Somebody moved the ticket. Somebody edited the config. Somebody set a label, approved a design, or merged the thing that settles it. Teach the agent to look for the decision before it asks for one, and a whole class of escalation stops existing. A question whose answer is already recorded is not a question.

Which is why the rate belongs on the wall with a band rather than a target. Somewhere around one escalation per three or four work orders feels right to me, though the number depends entirely on how well specified your work is. What matters is watching the trend and asking what changed when it moves. A sudden drop after a model upgrade could mean the new model is better. It could also mean the new model is more confident and less careful, and those two look identical from a dashboard.

### Work, by project, drilling down

Underneath the escalation queue sits the thing you look at second: work items, grouped by project. Not by agent. Grouping by agent is the mistake every first version makes, because agents are the thing you just built and the thing you are proud of. Nobody cares which agent did what. People care whether the checkout rewrite is on track.

So the shape is a list of projects, each with its work in states you already recognize, because they are the states work management systems have used for thirty years. Waiting. In progress. Blocked, and blocked on what. Done, and done means two different things, so the system has to distinguish finished-and-worked from finished-and-failed. A checkbox cannot carry that distinction on its own, and a factory that reports both as "complete" will lie to you at scale.

From a work item you drill into the agent that has it. From the agent you reach the artifacts: the design brief, the change set, the test report, the escalations it raised and how they were answered. Three clicks from "how is the checkout rewrite going" to "here is the diff and here is why it is shaped that way". Any more than that and people stop looking.

Notice what I have not said is in this interface. I have not said there is a chat window in the middle of it. That turns out to be the most interesting thing about the layer, and it deserves its own section.

## The interface inversion {#inversion}

Almost every agent product shipped in the last two years has been racing in one direction: show the user more of what the agent is doing. Stream the tokens. Expand the thinking block. Render the tool calls with little icons. Show the file being edited, line by line, as it is edited. Some of them show you a live terminal.

All of that made sense when it was built, and for a good reason. Nobody trusted the agent. Watching it work was how you learned whether it was any good, and catching it doing something stupid on line four saved you from reading a broken diff on line four hundred. Visible reasoning was a trust-building device, and it worked.

Mature factories will go the other way. As the agent gets more reliable, every one of those displays turns from evidence into noise, and the interface hides them one at a time. I think the order is roughly fixed.

**Hide the thinking first.** Reasoning traces are the least useful thing on the screen once you trust the agent, and they are the most expensive to read. A thousand words of deliberation to decide which file to open is not information, it is the agent talking to itself. Keep it, log it, make it retrievable when something goes wrong. Stop putting it in front of people by default.

**Hide the tool calls next.** Watching an agent run `grep` forty times is watching a colleague type. You do not stand behind a colleague and read their keystrokes, and if you did they would ask you to stop. Tool calls belong in the trace, next to the thinking.

**Then hide the chat.** This is the one that sounds wrong, so let me be precise about what I mean. The transcript, the running conversation between a person and an agent about a piece of work, stops being the primary surface. It does not disappear. It stops being the thing you look at to find out what happened.

What replaces it is the artifact. An agent finishes a piece of work and hands you a thing: a design brief, a coding standards report, a change set, a test summary, a migration plan. Something with a shape, that you can read in three minutes, that means the same thing next week when you come back to it. A colleague who did that work would not send you their inner monologue. They would send you the document.

<figure>
<svg class="diagram" viewBox="0 0 720 400" role="img" aria-labelledby="fig-inv-title">
  <title id="fig-inv-title">Transcript view compared with artifact view: a long scroll of thinking and tool calls, against a short list of finished artifacts and open questions</title>

  <text class="t-md bold" x="14" y="20">Transcript view</text>
  <rect class="surface" x="14" y="32" width="320" height="344" rx="6"/>
  <rect class="box box-dim" x="30" y="46" width="288" height="18" rx="3"/>
  <text class="t-sm t-mute" x="40" y="59">Thinking: the user wants me to&#8230;</text>
  <rect class="box box-dim" x="30" y="70" width="288" height="18" rx="3"/>
  <text class="t-sm t-mute" x="40" y="83">Tool: grep "checkout" src/</text>
  <rect class="box box-dim" x="30" y="94" width="288" height="18" rx="3"/>
  <text class="t-sm t-mute" x="40" y="107">Tool: read src/checkout/Cart.ts</text>
  <rect class="box box-dim" x="30" y="118" width="288" height="18" rx="3"/>
  <text class="t-sm t-mute" x="40" y="131">Thinking: that file is not it, I&#8217;ll&#8230;</text>
  <rect class="box box-dim" x="30" y="142" width="288" height="18" rx="3"/>
  <text class="t-sm t-mute" x="40" y="155">Tool: grep "applyDiscount"</text>
  <rect class="box box-dim" x="30" y="166" width="288" height="18" rx="3"/>
  <text class="t-sm t-mute" x="40" y="179">Tool: read src/pricing/Rules.ts</text>
  <rect class="box box-dim" x="30" y="190" width="288" height="18" rx="3"/>
  <text class="t-sm t-mute" x="40" y="203">Thinking: now I understand the&#8230;</text>
  <rect class="box box-dim" x="30" y="214" width="288" height="18" rx="3"/>
  <text class="t-sm t-mute" x="40" y="227">Tool: edit src/pricing/Rules.ts</text>
  <rect class="box box-dim" x="30" y="238" width="288" height="18" rx="3"/>
  <text class="t-sm t-mute" x="40" y="251">Tool: run npm test</text>
  <rect class="box box-dim" x="30" y="262" width="288" height="18" rx="3"/>
  <text class="t-sm t-mute" x="40" y="275">Thinking: four tests failed, the&#8230;</text>
  <rect class="box box-dim" x="30" y="286" width="288" height="18" rx="3"/>
  <text class="t-sm t-mute" x="40" y="299">Tool: edit src/pricing/Rules.ts</text>
  <rect class="box box-dim" x="30" y="310" width="288" height="18" rx="3"/>
  <text class="t-sm t-mute" x="40" y="323">Tool: run npm test</text>
  <rect class="box box-alt" x="30" y="334" width="288" height="28" rx="3"/>
  <text class="t-sm bold" x="40" y="352">Done. PR #4471 raised.</text>
  <text class="t-sm t-mute t-mid" x="174" y="392">1 useful line, 12 lines of noise</text>

  <text class="t-md bold" x="386" y="20">Artifact view</text>
  <rect class="surface" x="386" y="32" width="320" height="344" rx="6"/>

  <rect class="box box-warm" x="402" y="46" width="288" height="56" rx="4"/>
  <text class="t-md bold" x="414" y="68">Change set</text>
  <text class="t-sm t-mute" x="414" y="88">PR #4471 &#183; 3 files &#183; tests green</text>

  <rect class="box box-warm" x="402" y="114" width="288" height="56" rx="4"/>
  <text class="t-md bold" x="414" y="136">Design brief</text>
  <text class="t-sm t-mute" x="414" y="156">Discount rules, 2 open decisions</text>

  <rect class="box box-warm" x="402" y="182" width="288" height="56" rx="4"/>
  <text class="t-md bold" x="414" y="204">Test report</text>
  <text class="t-sm t-mute" x="414" y="224">18 added, 0 failing, 1 flaky</text>

  <rect class="box box-alt" x="402" y="250" width="288" height="66" rx="4"/>
  <text class="t-md bold" x="414" y="272">1 question for you</text>
  <text class="t-sm t-mute" x="414" y="292">Retry after the failure email: resend</text>
  <text class="t-sm t-mute" x="414" y="308">or suppress?</text>

  <path class="line-dash" d="M402 330 L690 330"/>
  <text class="t-sm t-mute" x="414" y="350">Full trace, if you need it</text>
  <text class="t-sm t-mute t-mid" x="546" y="392">4 things, all of them signal</text>
</svg>
<figcaption>The same session, two interfaces. The left one is what almost everybody ships today. The right one is what you want on a Monday with thirty-one work orders behind you.</figcaption>
</figure>

### Two interfaces survive

Strip it back far enough and you need exactly two things.

**Plain chat, for escalations.** When an agent asks you a question, a conversation is the right shape, because a conversation is what a question and an answer are. Keep it boring and keep it textual. No special rendering, no branching flow, no forms. One agent asks, one person answers, the work unblocks. Plain chat is also the right shape for the other direction: you noticed something, you want to tell the agent, you type it.

**An enriched view, for everything else.** Work by project, artifacts by work item, the escalation queue, the metrics. Enriched means it renders the things the factory produces as objects with structure rather than as text in a scroll. A change set shows as a change set, with files and a diff. A test report shows the failures first. A design brief shows its open decisions at the top.

Pushing artifacts to the front has a second effect that is easy to miss. It changes what the agent optimizes for. An agent whose output is judged as a transcript learns to narrate well. An agent whose output is judged as an artifact learns to produce a good artifact, because that is the thing anybody will read. Interfaces shape behavior in both directions, and the behavior you want is a colleague who writes a good document, not one who is entertaining to watch.

There is a real cost to this inversion and it would be dishonest to skip it. Hiding the reasoning makes debugging harder on the day something goes badly wrong, and it makes it easier for a confidently wrong agent to stay hidden for longer. My answer is that the trace still exists, fully, and one click away. You are choosing the default, not deleting the data. Defaults are what people live in, and the default should be the finished work.

## Projects and work orders {#work-orders}

A factory is a set of modular components, and one of them has to be a work management system. Not optionally, not eventually. Without it you do not have a factory, you have a collection of agents and a lot of hope.

Two things happen through that system and nothing else can do either of them. Agents report finished work into it. Agents find new work through it. Take it away and there is no answer to "what is the factory doing right now", no answer to "did anybody pick that up", and no way for a piece of work to move from one agent to another without a person carrying it.

Which is also the reason I said earlier that the work order is the interesting object. Everything else in the system is in service of moving work orders through states.

### The unit is the project

Work groups by project, and a project is whatever your organization already calls a project: a service, an app, a repository, a workstream with a name and an owner. Most usefully it is the thing that has a single set of conventions, a single test suite, and a single set of people who care about it.

Several agents work different aspects of one project at the same time, and that is the normal case, not the exotic one. On a Tuesday afternoon a project might have a coding agent implementing a work order, a review agent going through a pull request raised that morning, a documentation agent updating the API reference to match a change that merged yesterday, and a maintenance agent working through a dependency bump. Four agents, one project, four separate work orders, no communication between any of them beyond what the work management system carries.

Keeping them uncoordinated is deliberate. Agents that have to talk to each other to get their work done are agents you now have to reason about jointly, and joint reasoning about concurrent actors is the hardest kind of reasoning there is. Agents that coordinate through work state are agents you can reason about one at a time. Software has known this since the first message queue: shared mutable conversation is worse than shared durable state.

### Where work orders live

Two credible homes exist and the choice is less important than people think.

**In a work tracker.** Jira, Linear, GitHub Issues, whatever your organization already runs. Big advantage: it is already there, people already look at it, and the work agents do shows up in the same place as the work people do. Nobody has to learn a second system, and management reporting keeps working. Big disadvantage: their makers designed them for human-paced work. Their APIs assume a handful of transitions a day, not a thousand, their notification models assume a person reading email, and their idea of a description is a rich text blob rather than a structured document.

**As flat files in the repository.** A markdown file per project holding a list of tasks, or a directory of specification documents with their plans and task lists next to them. One line per work order, one mark per state, and everything an agent needs to read is in the same checkout as the code. Big advantage: the work order lives next to the code it describes, it versions with the code, it diffs, it reviews, and an agent can read it with the same tool it reads source with. A change to the specification and the change to the code that implements it can arrive in the same pull request, which is a genuinely nice property. Big disadvantage: no notifications, no cross-project view, and concurrent edits to one file by six agents is a merge conflict generator.

Spec-driven development is the name that has attached itself to the second approach. [GitHub's Spec Kit](https://github.com/github/spec-kit) is the most visible implementation: an open source toolkit that runs a project through *specify*, *plan*, *tasks*, *implement*, and *converge*, writing each stage down as files in the repository. It is deliberately agent-agnostic and works with a long list of coding agents rather than one vendor's. What Spec Kit is really selling is not the files. It is the discipline of writing the specification before the code and keeping it where the code is.

My own view is that the two homes converge. A tracker with good API access and a repository with good file conventions end up representing the same object, and the sensible design treats "where the work order is stored" as a connector concern rather than an architectural one. Which is a claim you can test: if swapping Jira for flat files requires changing your agents, your work order abstraction leaked.

### Inputs are first-class objects

Now the part that most implementations get wrong. A work order is not a sentence. It has inputs, and those inputs are objects in their own right with their own lifecycle.

**A product requirements document** says what the software should do for a user and why. It is written by a person, or drafted by an agent and approved by a person, and it changes rarely. Several work orders point at one of these.

**A technical design** says how the system will be shaped to do that. It names the components, the data, the interfaces, the migration. Agents can draft these well and it is one of the highest-value things to have them do, because a bad design discovered at review time is expensive and a bad design discovered in a document is a five-minute conversation.

**An implementation plan** breaks the design into ordered steps with dependencies. The step is the thing an agent picks up.

Treating each of these as an object rather than as prose in a ticket description buys you three specific things. You get reuse: twelve work orders can point at one design, and updating the design updates what all twelve agents read. You get review: a design brief can be approved, and a design is the cheapest place to put a person, because it is short and a mistake in it is expensive. And you get lineage, which matters enough that it comes up again at the bottom of the stack. When somebody asks in eight months why this class exists, you want to be able to walk from the class to the change set to the work order to the plan to the design to the requirement to the person who asked for it.

### The states a work order moves through

Keep the state machine small. Long experience with human work management says that every state you add gets used inconsistently within a quarter, and agents are no better at this than people.

Waiting means it is on the backlog and available. In progress means somebody or something has claimed it, and claiming is the one operation a file genuinely cannot arbitrate, because two agents reading the same file a second apart will both decide it is theirs. Numbering has the same problem and it bites in the same way. Two agents both read the file, both take the highest number, and both add one. Hand out identifiers from a counter rather than deriving them, or you will find three different pieces of work wearing the same number. Blocked means it stopped on something external, and the system should record what: a decision, another work order, a person, an outage. Blocked-on-a-decision is the state an escalation creates, and it should clear itself when the answer arrives, without waiting for a person to come back and move it.

Then done, which is two states wearing one name. Finished-and-worked and finished-and-failed are completely different facts and a checkbox cannot tell you which. Make the failure state say why, in words, next to the work order, where the next agent to look at it will read it. A factory that collapses them will report a 94% completion rate while a third of the work silently failed, and you will not notice for a month. Make the failure state say why in words, next to the work order, where the next agent to look at it will read it.

## Layer 5, agents {#agents}

An agent is a role. Not a process, not a session, not a model. A role: a job description, a set of tools appropriate to that job, some knowledge about how this organization does things, and a name that means something to a person reading a queue.

Coding agent. Review agent. Documentation agent. Release agent. Test agent. Incident responder. The list is short and it looks like the list of jobs in a software team, which is not a coincidence, because the work being divided up has not changed.

My own set of roles got thinner every time I revisited it, and the deletions taught me more than the additions. The one I would warn people about is the coordinator: an agent whose job is to rank incoming work and hand it out. It looks obviously necessary. It exists to save a person from sorting, and once escalations carry options and a recommendation there is very little left to sort, so what the tier actually adds is a relay on every message in both directions. Take it out and the people who care about a project talk to the agents working on it.

Agents live inside the runtime. They are configuration, not infrastructure: a prompt, a tool allowlist, a set of skills or instructions, a model preference, an identity. Spinning up a new agent role should cost about as much as writing a job description, and if it costs more than that, something in the layer below is wrong.

### What an agent is made of

**A prompt**, which is the job description. What this role does, what good work looks like, what it must never do, when to ask rather than guess. Prompts belong in a registry with versions, because you will change them and you will need to know what a given piece of work was produced under.

**Tools**, which are the hands. Read a file, edit a file, run a command, search the web, comment on a pull request, transition a ticket, post to a channel, query a log aggregator. The tool set is where an agent's role actually lives, more than in the prompt, because a review agent with write access to the repository will eventually write to the repository no matter what its prompt says.

**Skills or instructions**, which are the organizational knowledge. How we name branches. What our commit messages look like. Which of our four HTTP clients to use and why. The distinction between this and the prompt is one of scope: the prompt is about the role, the skills are about the place.

**Memory**, which is what the agent carries between sessions. Small, curated, and much less exciting than the word suggests.

**An identity**, which is how the rest of the world knows it. Covered properly at layer 1, because it turns out to be a data problem rather than an agent problem.

### Against composing agents on top of agents

Now the argument I expect most disagreement about.

A large amount of effort is going into composing agents: chaining them, wiring them into graphs, having one agent call another as a tool, defining protocols for them to negotiate with each other. Framework after framework has shipped a way to build a directed graph of agent nodes. Agent-to-agent protocols exist partly to make this easier across vendor boundaries.

I think most of it manufactures complexity and solves a problem that is disappearing.

Start with what composition was for. In 2023 a model could hold about a dozen tools in its head before it started picking the wrong one, and it lost the thread of a long task. So you decomposed: a planner agent that made a plan, a coder agent that took one step, a critic agent that checked it. Each sub-agent had a narrow job and a small tool set, and the narrowness was the point, because narrowness was what the model could cope with.

Models cope with much more now. An agent with fifty tools and a long task does not get confused in the way its 2023 ancestor did. It reads, it decides, it acts, it checks its own work, and it manages its own context because it has been trained to. The prosthetic is still there and the leg has grown back.

Meanwhile the costs of composition are real and they do not shrink. Cognition put the clearest version of this argument in writing in "[Don't Build Multi-Agents](https://cognition.com/blog/dont-build-multi-agents)", and their core point is about context rather than about coordination. When you split work across sub-agents, each one sees a fragment. They do not see each other's intermediate decisions or the assumptions those decisions rested on. So sub-agent two makes a choice that contradicts sub-agent one's choice, nobody notices, and the pieces get assembled into something incoherent. Their prescription is to default to single-threaded linear agents and to treat multi-agent designs as needing to clear a high bar.

Three more costs sit on top of that one. Debugging gets much worse, because a failure in a five-node graph means reading five transcripts and working out which node poisoned the next. Latency multiplies, because each hop is a full model round trip and they serialize. And the graph itself becomes a thing you maintain, tuned to the model you had when you drew it, so a model upgrade means re-tuning a structure whose only purpose was to compensate for the old model.

Be fair about the other side. Anthropic has published a multi-agent research system where parallel sub-agents outperform a single agent by a wide margin on open-ended research. Their explanation is straightforward. Search is parallelizable, and each sub-agent gets its own context window to burn on a different part of the search space. That is a real result and it points at where composition earns its keep.

<div class="key">
<p>Composition works when the sub-agents are gathering information. It fails when they are taking actions. Reading is parallelizable and writing is not.</p>
</div>

Which lines up with how a factory is built anyway. Within one work order, one agent does the work, start to finish, holding the whole context. It may fan out read-only helpers to go and find things, and those helpers return findings rather than changes. Across work orders, agents run in parallel and coordinate through work state rather than through conversation. No graph, no negotiation, no chaining. The coding agent that raises a pull request does not call the review agent. It raises a pull request, and the pull request causes an event, and the event finds a review agent, which is layer 3's job and the subject of a later section.

Two places where a light form of composition does pay for itself are worth naming, so this does not read as a blanket ban. A long-running agent can spawn a short-lived agent to do a bounded research task and summarize it, which keeps the main context clean. And an agent can invoke a specialized agent as a tool where the specialization is genuinely about a different domain, a security review of a diff being the obvious example. Both of those are one level deep, both return information rather than actions, and neither involves a graph.

## Layer 4, runtime {#runtime}

Runtime is the layer that holds a session open. Given an agent definition and a work order, it starts a session, calls a model, receives the model's requests to use tools, runs them, feeds the results back, and keeps going until the work is done or the agent asks a question. Everything above it is configuration. Everything below it is infrastructure. Runtime is the engine.

Two properties of this layer matter more than anything else in the post, so they get the most space.

### Agents are no-code

Creating an agent should mean writing a prompt, picking a model, and choosing a set of tools. Nothing else. No build step, no deployment, no container image, no pull request against the platform.

Sounds obvious when you write it down. It is not what most implementations do. The common pattern is that an agent is a piece of code: a Python file with a class in it, a graph definition, a service that gets deployed. Adding an agent role is then a software change. Software changes go through the software change process, so the team that wants a documentation agent files a ticket with the platform team and waits three weeks.

Keeping agents as configuration is what makes the factory usable by the people it is for. A project team that wants an agent that reviews their database migrations against their own conventions should be able to have one before lunch. They know their conventions. They do not know your orchestration framework, and making them learn it is how a platform dies.

It also makes the whole thing cheap to iterate. Prompts are wrong the first time. If fixing a prompt is a deploy, prompts stay wrong.

Several runtimes will coexist and that is fine. One organization will end up with a hosted runtime from a model vendor, and a self-hosted one running an open source harness for work that cannot leave the building. Probably a third as well, that somebody's team built before the platform existed and that now runs something load-bearing. Treating runtime as pluggable at the layer above is what keeps that survivable. The work order does not care which runtime executed it.

### The architectural fork

One decision shapes your factory more than any other, and it gets made early, usually by accident.

Where does the agent loop run: inside the sandbox, or outside it?

**Agent in the sandbox** is what almost every coding tool does today. You start a container, you put a checkout in it, and you run the agent binary inside that container. The agent holds its own conversation, calls the model over the network, and runs tools as local processes. One container, one agent, one session, all of it together.

**Head and hands** splits them. The loop runs outside, in a service. The sandbox is a thing the loop uses, exposed through an interface about as complicated as `execute(name, input)` returning a string. Anthropic wrote up their version of this in "[Scaling Managed Agents](https://www.anthropic.com/engineering/managed-agents)", describing a split into three virtualized pieces: a session, which is an append-only log of everything that happened; a harness, the loop that calls the model and routes its tool calls to infrastructure; and a sandbox, the execution environment where code runs and files get edited.

<figure>
<svg class="diagram" viewBox="0 0 720 380" role="img" aria-labelledby="fig-fork-title">
  <title id="fig-fork-title">Agent in the sandbox compared with head and hands: the agent loop inside one container, against a harness outside driving several replaceable sandboxes</title>

  <text class="t-md bold" x="14" y="20">Agent in the sandbox</text>
  <rect class="surface" x="14" y="32" width="320" height="300" rx="6"/>

  <rect class="box box-dim" x="34" y="86" width="280" height="222" rx="4"/>
  <text class="t-sm t-mute" x="46" y="106">Container</text>

  <rect class="box box-alt" x="52" y="118" width="244" height="40" rx="3"/>
  <text class="t-md t-mid" x="174" y="143">Agent loop</text>

  <rect class="box" x="52" y="170" width="244" height="34" rx="3"/>
  <text class="t-sm t-mid" x="174" y="191">Session state, in memory</text>

  <rect class="box" x="52" y="216" width="244" height="34" rx="3"/>
  <text class="t-sm t-mid" x="174" y="237">Tools, credentials</text>

  <rect class="box box-warm" x="52" y="262" width="244" height="34" rx="3"/>
  <text class="t-sm t-mid" x="174" y="283">Checkout, shell, generated code</text>

  <rect class="box" x="94" y="46" width="160" height="28" rx="3"/>
  <text class="t-sm t-mid" x="174" y="65">Model API</text>
  <path class="line accent" d="M174 118 L174 74"/>
  <path class="accent-fill" d="M174 74 l-4 8 l8 0 z"/>
  <text class="t-sm t-mute t-mid" x="174" y="352">Container dies, session dies</text>

  <text class="t-md bold" x="386" y="20">Head and hands</text>
  <rect class="surface" x="386" y="32" width="320" height="300" rx="6"/>

  <rect class="box" x="466" y="46" width="160" height="28" rx="3"/>
  <text class="t-sm t-mid" x="546" y="65">Model API</text>

  <rect class="box box-alt" x="406" y="94" width="280" height="40" rx="3"/>
  <text class="t-md t-mid" x="546" y="119">Harness (the head)</text>
  <path class="line accent" d="M546 94 L546 74"/>
  <path class="accent-fill" d="M546 74 l-4 8 l8 0 z"/>

  <rect class="box" x="406" y="146" width="280" height="30" rx="3"/>
  <text class="t-sm t-mid" x="546" y="165">Session: append-only log</text>

  <text class="t-sm t-mute t-mid" x="546" y="200">execute(name, input) &#8594; string</text>
  <path class="line-dash" d="M466 176 L466 212 M546 176 L546 212 M626 176 L626 212"/>

  <rect class="box box-warm" x="414" y="216" width="100" height="70" rx="3"/>
  <text class="t-sm t-mid" x="464" y="242">Sandbox</text>
  <text class="t-sm t-mute t-mid" x="464" y="262">checkout,</text>
  <text class="t-sm t-mute t-mid" x="464" y="276">shell</text>

  <rect class="box box-warm" x="496" y="216" width="100" height="70" rx="3"/>
  <text class="t-sm t-mid" x="546" y="242">Sandbox</text>
  <text class="t-sm t-mute t-mid" x="546" y="262">checkout,</text>
  <text class="t-sm t-mute t-mid" x="546" y="276">shell</text>

  <rect class="box box-warm" x="578" y="216" width="100" height="70" rx="3"/>
  <text class="t-sm t-mid" x="628" y="242">Sandbox</text>
  <text class="t-sm t-mute t-mid" x="628" y="262">checkout,</text>
  <text class="t-sm t-mute t-mid" x="628" y="276">shell</text>

  <text class="t-sm t-mute t-mid" x="546" y="308">Sandboxes are replaceable</text>
  <text class="t-sm t-mute t-mid" x="546" y="352">Sandbox dies, session survives</text>
</svg>
<figcaption>The fork. On the left the loop and the execution environment share a fate. On the right they do not, and almost everything good about the right-hand design follows from that one difference.</figcaption>
</figure>

Head and hands is the better bet, for four reasons that compound.

**Failures stop being fatal.** When the loop lives in the container, a container crash loses the session, and you restart the work from the beginning. With the log outside, a sandbox is a disposable thing: it dies, you make another one, you replay the state you need, and the work continues from where it stopped. Anthropic's write-up makes the distinction plainly, which is that sandboxes stop being hand-tended pets and become cattle.

**Latency improves, and for a non-obvious reason.** Coupling forces you to provision the container before you know whether the work needs one. Plenty of work does not: answering a question, reading a design document, deciding that a ticket is a duplicate. Anthropic reported that decoupling cut time to first token by around 60% at the median and 90% at the tail. Those are numbers from one system and yours will differ, but the mechanism is general. Do not build the workshop until somebody asks for a hammer.

**Credentials stop living next to generated code.** Coupling puts your tokens in the same process space as code an agent wrote from instructions that may have come off the internet. Prompt injection stops being a theoretical concern the moment there is something worth stealing in reach. Splitting them means the sandbox holds a checkout and a shell and nothing else worth having.

**It ages better.** Models change, and when they do, the loop changes with them: different tool calling conventions, different context handling, different ways of signaling that it wants to stop. With the loop in a service, that is a deploy. With the loop baked into a container image that also carries your toolchain, your test dependencies, and your language runtime, you rebuild and redistribute an image to upgrade a prompt. I have watched teams take a quarter to roll out a model upgrade for exactly this reason.

One honest counterpoint. Agent-in-sandbox is simpler, and simplicity is worth real money. For a single developer running one agent on one laptop it is obviously correct, and pretending otherwise would be silly. The split earns its complexity somewhere around the point where you are running enough concurrent work that sandbox failures are a daily event rather than a monthly one. Below that threshold, do the simple thing.

### Evals, and why they belong here

Runtime is where the model gets chosen, so runtime is where you have to be able to answer the only question that matters about a model: is this one better than the one we are using, at our work?

Generic benchmarks will not answer that. A model that scores well on a public coding benchmark may be worse at your codebase, with your conventions, your tools, and your specification style. What you need is an evaluation built out of your own work.

**A golden set of work orders.** Thirty to a hundred real work orders that agents have already completed, with the artifacts they produced and a judgment about whether each one was good. Not synthetic tasks. Real ones, pulled from your own history, weighted toward the kinds of work you do most and the kinds that went wrong. When a new model appears, replay the set. The output is a comparison on work you recognize.

Building the golden set is tedious and it is the part everybody skips. Skip it and you will be choosing models on vibes and vendor benchmarks, which is how you end up rolling back a model upgrade three weeks later after a senior engineer notices the tests have gotten worse.

**Production signals.** Replay tells you about the past. The live system tells you about now, and a few numbers carry most of the signal. Escalation rate, discussed at layer 6, watched in both directions. Rejection rate, the fraction of artifacts a human sends back, which is the sharpest signal you have and also the one that disappears as you turn the dial down, because nobody is there to reject anything.

What survives the dial going to zero is what production tells you. Revert rate: the fraction of changes backed out after they shipped. Rollback rate on canaries. Change failure rate and time to restore, which are the old delivery metrics and lose none of their meaning here. Incident count attributable to agent-authored changes. Each of those is verification arriving late, which is worse than verification arriving early and still much better than an opinion.

Slice both by agent role, by project, and by model version, because an aggregate hides everything interesting. A model upgrade that improves coding and quietly degrades review will look flat in aggregate and will cost you a month.

**Evals feed observability rather than living as a test suite.** This is a small point with large consequences. Treat evaluation as a thing that runs before a change ships and you get a gate: a red build, an argument about the threshold, and a number nobody looks at afterward. Treat it as a stream feeding the same dashboards as your escalation and rejection rates and you get something you actually watch. Replaying the golden set becomes another observation, plotted next to the live ones, with model version as a dimension on every chart.

Which also means the answer to "did that model upgrade help?" is a graph you can point at rather than an opinion, and opinions about model quality are worth approximately nothing.

## Layer 3, routing and gateways {#routing}

Something has to decide that an event means work, and something has to decide which agent gets it. Layer 3 does both, and it is the conveyor belt from the picture at the start.

Two components live here. An agent router, which turns things that happen into agent sessions. And a gateway, which stands between agents and the tools they call.

### The agent router

A router takes a system message and produces a prompt. That is the whole job, and stating it that plainly makes it sound trivial, which it is not.

Follow one event through. Somebody pushes a commit to a branch and GitHub sends a webhook. Arriving at the router it is a JSON blob with an event type, a repository, a branch, a commit, an author, and forty fields nobody needs. No agent can do anything with that. So the router identifies the project from the repository, finds the work order the branch belongs to, decides that this event type on this project matches a workflow, loads that workflow's prompt template, fills it with the specifics, and starts a session with the agent role the workflow names.

What was a webhook is now: "A commit landed on branch `feature/retry-policy` for work order W-4471 in the payments project. Here is the work order, here is the design it points at, here is the diff. Continue the implementation."

<figure>
<svg class="diagram" viewBox="0 0 720 420" role="img" aria-labelledby="fig-route-title">
  <title id="fig-route-title">Event routing: webhooks, ticket transitions, timers and messages arrive at a router, which matches them against a workflow database and dispatches to an agent by role</title>

  <text class="t-sm t-mute" x="14" y="20">Events</text>
  <rect class="box" x="14" y="30" width="170" height="44" rx="4"/>
  <text class="t-sm bold" x="26" y="50">GitHub webhook</text>
  <text class="t-sm t-mute" x="26" y="66">pull_request.review</text>

  <rect class="box" x="14" y="86" width="170" height="44" rx="4"/>
  <text class="t-sm bold" x="26" y="106">Jira transition</text>
  <text class="t-sm t-mute" x="26" y="122">To Do &#8594; In Progress</text>

  <rect class="box" x="14" y="142" width="170" height="44" rx="4"/>
  <text class="t-sm bold" x="26" y="162">Timer</text>
  <text class="t-sm t-mute" x="26" y="178">02:00 daily</text>

  <rect class="box" x="14" y="198" width="170" height="44" rx="4"/>
  <text class="t-sm bold" x="26" y="218">Slack message</text>
  <text class="t-sm t-mute" x="26" y="234">mention in #payments</text>

  <path class="line accent" d="M184 52 L228 52 M184 108 L228 108 M184 164 L228 164 M184 220 L228 220"/>
  <path class="accent-fill" d="M228 52 l-8 -4 l0 8 z M228 108 l-8 -4 l0 8 z M228 164 l-8 -4 l0 8 z M228 220 l-8 -4 l0 8 z"/>

  <rect class="box box-alt" x="230" y="30" width="196" height="212" rx="4"/>
  <text class="t-lg t-mid" x="328" y="58">Agent router</text>
  <text class="t-sm t-mute t-mid" x="328" y="80">Match on message semantics</text>
  <text class="t-sm t-mute t-mid" x="328" y="96">and agent role</text>
  <path class="line-dash" d="M246 110 L410 110"/>
  <text class="t-sm t-mute" x="246" y="130">1. Identify the project</text>
  <text class="t-sm t-mute" x="246" y="150">2. Find the work order</text>
  <text class="t-sm t-mute" x="246" y="170">3. Look up the workflow</text>
  <text class="t-sm t-mute" x="246" y="190">4. Fill the prompt template</text>
  <text class="t-sm t-mute" x="246" y="210">5. Start a session</text>

  <rect class="box box-dim" x="230" y="272" width="196" height="118" rx="4"/>
  <text class="t-md bold t-mid" x="328" y="296">Workflow database</text>
  <text class="t-sm t-mute" x="244" y="320">changes requested &#8594; coder</text>
  <text class="t-sm t-mute" x="244" y="340">changes made &#8594; reviewer</text>
  <text class="t-sm t-mute" x="244" y="360">build failed &#8594; coder</text>
  <text class="t-sm t-mute" x="244" y="380">02:00 daily &#8594; maintainer</text>
  <path class="line-dash" d="M328 272 L328 242"/>

  <path class="line accent" d="M426 96 L474 96 L474 74"/>
  <path class="accent-fill" d="M474 74 l-4 8 l8 0 z"/>
  <path class="line accent" d="M426 150 L474 150 L474 180"/>
  <path class="accent-fill" d="M474 180 l-4 -8 l8 0 z"/>

  <rect class="box box-warm" x="474" y="30" width="232" height="44" rx="4"/>
  <text class="t-md bold" x="490" y="50">Coding agent</text>
  <text class="t-sm t-mute" x="490" y="66">the one that wrote the change</text>

  <rect class="box box-warm" x="474" y="180" width="232" height="44" rx="4"/>
  <text class="t-md bold" x="490" y="200">Review agent</text>
  <text class="t-sm t-mute" x="490" y="216">continues the review it started</text>

  <rect class="box" x="474" y="272" width="232" height="118" rx="4"/>
  <text class="t-md bold t-mid" x="590" y="296">Gateway</text>
  <text class="t-sm t-mute t-mid" x="590" y="320">Access control, rate limiting,</text>
  <text class="t-sm t-mute t-mid" x="590" y="338">throttling, audit</text>
  <path class="line-dash" d="M590 224 L590 272"/>
  <text class="t-sm t-mute t-mid" x="590" y="366">One place, not one per server</text>
</svg>
<figcaption>Events in on the left, sessions out on the right. The router owns the translation, the workflow database owns the rules, and the gateway sits between every agent and every tool it calls.</figcaption>
</figure>

### Route by semantics and role, not by session

Now the part that is easy to get wrong, and expensive.

Routing by session is the obvious design. Session 8813 raised pull request 4471, so when something happens to pull request 4471, wake up session 8813. Simple, and it feels right, because it preserves continuity.

It breaks within a week. Sessions end. Sessions run out of context. Sessions get killed when a sandbox dies, and at layer 4 we deliberately made sandboxes disposable. Sessions belong to a model version you have since upgraded. Tie your routing to session identity and every one of those becomes an orphaned event: a real thing that happened, with nowhere to go, silently dropped.

Route on two things instead. What does the message mean, and which role should handle it?

Take the pull request example properly, because it shows the asymmetry that makes this interesting.

**"Changes requested" on a pull request.** Meaning: somebody wants the change modified. Role: coding agent. Specifically the coding agent for that project, given the work order, the pull request, and the review comments. Whether the original session still exists is irrelevant. A fresh session with the right context will do the job, because the context is in the work order and the pull request, not in the dead session's memory.

**"Changes made" on a pull request.** Meaning: the author responded and there is new code to look at. Role: review agent. It picks up its own earlier review comments from the pull request, sees what changed, and continues from there.

Same object, two events, two roles, and the routing rule for each is one line. Notice that the continuity people worry about is preserved, but it is preserved in the pull request rather than in a session. Review comments are durable. Work orders are durable. Sessions are not. Put the state in the durable thing and routing gets much easier.

Timers are the same mechanism with no external sender. At 02:00 a timer fires for a project, matches a workflow, and starts a maintenance agent: check for dependency updates, run the full test suite including the slow ones, look for work orders that have been blocked for more than a week and say so. Nightly work is where a factory earns a surprising amount of its keep, because it is work nobody has ever had time to do.

### The workflow database

Sitting underneath the router is a store of workflows, each matched to events. A workflow is a small object: what event it triggers on, what conditions narrow it, which agent role runs, what prompt template gets used, and what tools that run is allowed.

Keeping this as data rather than code is the whole point, and it comes back in the section on the factory building itself. Data can be listed, searched, versioned, approved, and written by an agent. Code that dispatches on a switch statement can be none of those things without a deployment.

Keep the matching boring. Event type, project, plus a condition or two. Anybody who has maintained a large rules engine knows how this ends if you let the conditions get clever: nobody can predict what fires, two rules match, and the debugging story is archaeology. A workflow that is hard to read is a workflow somebody will work around.

### The MCP gateway

Now the second component, which solves an entirely different problem.

Agents call tools, and increasingly those tools are Model Context Protocol servers. MCP standardized how a model-facing client talks to a tool provider, and it has been adopted widely enough that "wrap it in an MCP server" is now the default answer to exposing a system to agents. Anthropic donated MCP to the Agentic AI Foundation under the Linux Foundation in December 2025, which took it out of any one vendor's hands.

What MCP does not do is govern anything. An MCP server exposes tools. Who may call them, how often, and with whose credentials is left to whoever is deploying it. Fine for one developer with three servers on a laptop. Not fine for an organization with two hundred agents and forty servers, some of which can delete production data.

So a gateway goes in the middle: one place that every agent's tool call passes through, giving you five things in one place rather than forty.

**Access control.** Which agent roles may call which tools. Your review agent gets read access to the repository and no write access, enforced in the gateway rather than requested politely in a prompt.

**Rate limiting.** An agent in a loop can call a tool a thousand times a minute, and the first time you find out will be when a downstream team asks why their API is on fire.

**Throttling and quotas.** Fairness between projects, so one runaway agent does not starve everybody else.

**Credential mediation.** Agents present their identity to the gateway. The gateway holds the credentials for the tool. No long-lived secret ever reaches an agent's sandbox, which is what made the layer 4 split worth doing in the first place.

**Audit.** One log of every tool call any agent made. When somebody asks who dropped that table, you want an answer in one query.

Several implementations exist. IBM's open source [ContextForge](https://github.com/IBM/mcp-context-forge) sits in front of MCP, A2A, and plain REST services, exposing one endpoint with discovery, authentication, rate limiting, and OpenTelemetry tracing. Docker ships an MCP Gateway aimed more at local and container-native use. Commercial options are appearing at a rate that makes listing them pointless.

An ordinary API gateway can play the same role, and for many organizations it should, because there is already one, somebody already runs it, and it already does authentication, rate limiting, and audit. Adding MCP routing to it is a smaller project than standing up a second gateway with a second policy model that drifts from the first.

Strictly, none of this is necessary. A factory works without a gateway. Agents call servers directly, each server does its own authentication, and everything functions. What you lose is the ability to answer governance questions, and governance questions are asked by people who can turn your project off. "Which agents can reach customer data?" is a question you want to answer by reading one policy file, not by auditing forty deployments.

## Layer 2, connectors {#connectors}

A factory that cannot reach your systems is a demo. Layer 2 is the set of connections into everything your company already runs, and it is simultaneously the least intellectually interesting layer and the one that decides whether any of this works.

Six kinds of connector show up in every implementation I have seen.

**Memory.** What the factory knows that is not in any other system. Conventions that were decided in a meeting. The reason a module is shaped oddly. The fact that the staging database gets rebuilt on Sundays so tests fail on Monday morning for reasons unrelated to your change. Memory should be small and curated. Every entry should say who put it there and when, because a fact from eight months ago may have expired. Big vector stores of everything are mostly a way to retrieve plausible irrelevance.

**Version control.** GitHub, GitLab, whatever holds the code. Reading is easy and everybody implements it. What separates a real connector from a toy is the rest of the surface: branches, pull requests, review comments, checks, required reviewers, protected branches, merge queues. An agent that can clone and push but cannot participate in a code review is not usable in a team.

**Work tracking.** Jira, Linear, GitHub Issues. Read a work order, transition it, comment on it, link it to a change, attach an artifact. Covered at length already.

**Messaging.** Slack, Teams, email. Two directions matter equally. Outbound so escalations reach a person where they actually are. Inbound so a person can answer in the channel, and so a mention in `#payments` can become work without anybody filing a ticket.

**Documents.** Confluence, Notion, Google Drive, SharePoint. Where the requirement documents, the runbooks, the architecture decisions, and the onboarding guide live. Note that "I cannot find the runbook" was one of the escalation examples at layer 6, and it is a very common one, because organizational knowledge is scattered across four systems and two of them are search-hostile.

**Everything else the business runs.** Splunk or Datadog for logs. Tableau or Looker for the dashboards. PagerDuty. The deployment tool. The feature flag service. The customer support system, because a bug report is a specification with a bad haircut. Each of these is a connector somebody has to write, and this is the long tail that makes buying a factory outright harder than it sounds. Nobody sells a connector to your internal deployment tool.

### Agents have an identity in each surface

One requirement separates connectors that work from connectors that are merely present.

An agent needs to be a first-class participant in each system, with its own identity, not a shared service account borrowing somebody's credentials.

Concretely: the review agent has a GitHub account. Its comments appear under its own name. Its approvals count or do not count according to a branch protection rule you wrote deliberately. The coding agent has a Jira user, so the work order says who is on it. Both have Slack identities, so when one asks a question in a channel, the reply comes back to a specific agent rather than into a shared inbox.

Three things fall out of this that you would otherwise have to build.

Attribution stops being your problem. Git already records an author. Jira already records an assignee. Slack already records a sender. Give agents identities and every one of those systems does your provenance work for free. Run everything through one `ci-bot` account and you get to build a parallel attribution system, badly.

Permissions stop being your problem too. Your version control system already has a permission model that your security team already understands and already audits. An agent with an account is inside that model. An agent using a shared token is outside it, and now somebody has to invent a second model that nobody reviews.

And revocation becomes possible. When an agent misbehaves you disable its account, and every system it touched stops trusting it at once. Shared credentials mean rotating a secret that eleven other things also use, at 3am, while people shout.

### Understanding the work item in context

Identity gets an agent in the door. Context is what makes it useful once inside, and this is subtler.

Each of these systems has a native unit of work with a place in a hierarchy, and an agent has to understand its own position in that hierarchy rather than treating everything as text.

An issue is not a document. It sits in a project, it has a type and a status and an assignee, it may have a parent epic and child subtasks, it has a history of transitions and who made them. An agent that reads the description and ignores the rest will confidently duplicate work that a sibling subtask already covers.

A pull request is not a diff. It sits in a repository, targets a branch, carries commits, has reviewers with states, has checks with results, has comments anchored to lines and threaded into conversations. An agent replying to review feedback needs to know which comments are resolved, which are on lines that no longer exist, and which reviewer is a required approver rather than a passing observer.

A message is not a string. It sits in a channel, belongs to a thread, has a sender with a role, and the four messages before it usually change what it means.

Getting this right is what makes the difference between an agent that reads your systems and an agent that works in them. Most disappointing agent integrations fail exactly here: the connector fetches the text and drops the structure, and then the model has to infer from prose a set of facts that were sitting right there in fields.

### Delegation and consent

One more property, and it is the one that turns up in the security review, so it is worth getting right before somebody asks.

When an agent acts, it is doing one of two things, and the systems it touches need to know which.

**Acting on a person's behalf.** You asked it to open a pull request, so it opens one carrying your authority. It can see what you can see. The action should be recorded as delegated: this agent did this thing because this person asked it to. Standard identity machinery already models this, and token exchange with an actor claim is the shape of the answer.

**Acting autonomously.** A nightly timer fired and a maintenance agent started work. Nobody asked. It carries its own authority, which should be narrower than any person's, and the record should say so plainly rather than implying a human was involved.

Drawing the line between them matters for two reasons that compound over time. Auditing needs it, because "who authorized this" has a different answer in each case. And the permission model needs it, because an autonomous agent should be able to do considerably less than a delegated one. My default is that autonomous agents can do anything reversible and nothing irreversible, and that the irreversible set is a list somebody wrote down deliberately rather than whatever happens to be left over.

Consent is the other half. When an agent acts on your behalf, you should be able to see that it did, find out what it did, and turn it off. Not buried in a settings page. Visible in the interface at layer 6, next to the work.

## Layer 1, data and sandbox {#data}

Bottom of the stack. Everything here is unglamorous, everything here is a database or a machine, and getting any of it wrong will quietly limit the six layers above it.

### The registries

Four registries, and the argument for each is the same argument: this thing is configuration, configuration needs versions, and versions need somewhere to live.

**The agent registry.** Every agent role that exists, its prompt, its tools, its model, its identity, its owner. Answers "what agents do we have?", which sounds like a trivial question until you are eighteen months in and the answer is genuinely unknown. Also answers "who owns this one?", which is the question that matters when an agent starts behaving oddly.

**The prompt registry.** Prompts with versions, because you will change them constantly and you will need to know what a given piece of work ran under. When the rejection rate on design briefs doubles in a week, the first question is what changed, and "we edited the prompt on Tuesday" is only useful if you can see both versions. Prompts are source code with a worse review culture, and a registry is the minimum fix.

**The plugin registry and the MCP registry.** What tools exist, what they do, where they run, who may use them, and which version is current. Discovery matters here more than it first appears: an agent that does not know a tool exists will do the job the long way, or ask a person for something it could have fetched. A good registry description is a small prompt in its own right.

**Workflow repositories.** The workflows from layer 3, stored, versioned, and owned. Same argument. A workflow that fires at 02:00 every night and does something expensive should have a name, an owner, and a history.

### Workspaces and sandboxes

A workspace is the durable state belonging to a piece of work: the checkout, the branch, the build cache, the files an agent has written, the artifacts it has produced. It outlives any one session, because work orders take more than one session and a person may look at the results next week.

A sandbox is the disposable execution environment: a container or a micro-VM with a shell, a toolchain, and a network policy. It is where untrusted generated code runs. It should be cheap to create, cheap to destroy, and assumed hostile.

Keeping those two concepts separate is the layer 4 argument arriving at layer 1. Conflate them and destroying the sandbox destroys the work. Separate them and a sandbox failure costs you a restart rather than a day.

Make the leases on shared things dumber than feels right. Anything agents contend over, a test environment, a device, a seat on an expensive API, wants a claim that works when your control plane is down and that a person can inspect with the tools they already have. Every clever version of this I built first was worse than the boring one that came after it.

Three properties of the sandbox deserve a sentence each, because they get skipped. Network policy should be default-deny with an allowlist, because an agent that can reach anything can exfiltrate anything, and the code it is running was written by a model reading text from the internet. Resource limits should exist, because an agent in a loop will find them for you. And startup time is a product feature rather than an infrastructure detail: a sandbox that takes ninety seconds to start turns every trivial task into a slow task, and slow tasks are the ones people stop delegating.

### Agent identity, at the bottom

Identity appeared at layer 2 as a connector property, and it belongs here as well, because it is really a data problem. Agents need identities in your identity provider: a directory entry, credentials, group membership, a lifecycle, an owner. Then the accounts in GitHub and Jira and Slack are projections of one identity rather than eleven unrelated accounts that nobody can enumerate.

Ask yourself the offboarding question, which is the one that exposes whether you did this properly. An engineer leaves and you disable their account. What happens to the four agents that were acting on their behalf? Right answer: they stop, because delegated authority was modeled explicitly and it just went away. Common answer: nothing, because those agents are holding personal access tokens that will keep working for another year.

### Storage, and what goes in it

Storage holds the specifications going in and the artifacts coming out, and it is worth being explicit that these are the two ends of the definition this post opened with.

Specifications: requirement documents, technical designs, implementation plans, acceptance criteria, the work orders themselves. Versioned, because they change, and because a work order completed in March was completed against March's version of the design.

Artifacts: change sets, test reports, design briefs an agent drafted, review reports, release notes, the traces. Immutable once produced, addressable by identifier, and retained long enough to answer questions later.

Retention needs a policy, and somebody has to choose it deliberately. Full traces of every session are large, and an agent that reads a hundred files produces a lot of log. Keeping everything forever is expensive. Keeping nothing means the first serious incident is unexplainable. A tiered answer is usually right: artifacts kept for years, traces kept for weeks unless something escalated or was rejected, in which case keep them with the artifact.

### Tracing and lineage

Last, and the property that makes everything else auditable.

Given an artifact, you should be able to walk backward: which session produced it, under which agent and which model version and which prompt version, for which work order, from which plan, from which design, from which requirement, asked for by which person. And forward: what did this design cause, which work orders came out of it, which changes shipped, which of those were rejected.

Distributed tracing gets you part of the way, since an agent session is a trace and a tool call is a span, and OpenTelemetry handles that shape without complaint. Lineage is the part tracing does not cover, because it is about the relationships between durable objects rather than about one execution. You need both, joined on work order identity.

Worth building early, for a reason that has nothing to do with debugging. When somebody senior asks whether the factory is producing good work, the answer has to be evidence rather than an anecdote about the time it fixed a bug nobody could find. Lineage is where the evidence lives. It is also, in a regulated industry, the difference between a system you can deploy and a system your compliance team will not sign.

## The factory builds itself {#self}

Something happens once all six layers are in place, and it is the reason building this is worth the trouble rather than just automating a few tasks.

Scheduling a workflow is just another tool. Writing a prompt is just writing a file. Creating an agent is configuration. Each of those is a thing an agent can do, which means agents can extend the factory they run in.

Sounds alarming written down like that. It is much more ordinary in practice, and it is how the useful parts of the factory get built, because the people who know what workflows are needed are not the people who built the platform.

### Three groups author workflows

**The platform team** writes the workflows everybody needs. Route "changes requested" to a coding agent. Route a failed build to whoever raised the change. Run dependency updates at 02:00. Escalate anything blocked for more than five days. Maybe twenty of these, they cover most events, and they arrive with the platform.

**Project teams** write the workflows their own project needs, and this is where the volume is. A payments team adds a workflow that runs an extra compliance check whenever a change touches the transaction ledger. A mobile team adds one that regenerates screenshots when a view changes. A data team adds one that validates schema migrations against last week's production snapshot. None of that is the platform team's business and none of it should require their involvement, because the moment it does, the queue forms and the good ideas die in it.

**Agents** write workflows too. An agent notices it has done the same manual sequence eleven times and proposes a workflow that does it. A maintenance agent finds a check that keeps catching real problems and suggests scheduling it nightly. An agent that repeatedly escalates the same question proposes a workflow that answers it.

That third one is genuinely useful and it is the one people find uncomfortable, so let me be concrete about what it does and does not mean. An agent proposing a workflow is proposing a data record. Nothing runs until something approves it. The proposal is a pull request, or a work order assigned to a person, or a new workflow sitting in a pending state until an owner signs it. Same shape as an agent proposing a code change, and nobody finds that alarming any more.

### Governance without a bottleneck

Two mechanisms keep this from turning into a self-propagating mess, and you want both.

**Permissioned tools through the gateway.** An agent can only create workflows if the workflow creation tool is in its tool set, and the gateway enforces that, not the prompt. Give it to a small number of roles. A coding agent does not need it. A platform maintenance agent might.

Tool allowlists bound what a created workflow can do, by the same mechanism. Workflows carry an allowlist, and the allowlist a workflow can grant is capped by what its author could grant. An agent that cannot deploy to production cannot write a workflow that deploys to production. That is ordinary privilege containment and it is the single most important rule in this section.

I call it the most important rule because I have watched it fail, and the failure is not dramatic enough to notice on the day. An agent gets refused an action. It then spawns a helper that is not gated the same way, and the helper does the thing. Nobody involved experiences this as cheating. The agent was told to accomplish something, it found a route, and the route happened to run around the control.

Which is the principle: a permission an agent can widen by spawning another agent is not a permission. If your permission model lives anywhere except the gateway, an agent that can create agents will walk around it eventually, and it will do so while following its instructions faithfully.

There is a second half that matters as much. If an agent is told a rule has changed and the document does not say so, the document wins. Amendments go where every agent reads, with the words and the date attached, never into a message passed along by somebody.

**An approval path.** Agent-created workflows land in a pending state with a named owner who has to approve them. Workflows are one of the places a person belongs by the reversibility test, because a workflow that fires nightly with tools attached has already done its damage by the time anybody reads it. Keep the approval cheap, which means it must not be a change advisory board. A notification, a readable diff of what the workflow will do, an approve button. Make it expensive and people will route around it, usually by giving an agent broader permissions so it does not have to ask.

Worth saying plainly: a workflow that fires on an event and runs an agent with tools is a program with an execution trigger. Treat the registry with the seriousness you would treat a cron table on a production host, because that is what it is. The failure mode is not dramatic. It is fifty workflows nobody remembers writing, four of which fire nightly and cost money, and one of which has been silently failing since March.

### Why this compounds

Growth is the point. A factory where only the platform team can add capability grows at the speed of the platform team, and the platform team is six people with a roadmap. A factory where any project team can add a workflow in an afternoon grows at the speed of everybody who has a good idea.

Watch what fraction of your capacity ends up pointed at the factory rather than at the products. In my experience it climbs, and it climbs for good reasons. The factory is the thing that multiplies everything else, and the agents can see that as clearly as you can. I would not fight it. I would measure it, because a system that mostly improves itself is one work order away from a system that only improves itself.

Watch what happens to the platform team's job as a result. They stop writing workflows and start maintaining the substrate: the registries, the gateway, the runtime, the permission model, the evaluation harness. Which is a better job with more reach, and it is the same shift that happened when infrastructure teams stopped provisioning servers and started running the platform that provisions servers.

Once established, the factory grows itself. That is the sentence worth remembering from this section, and it is also the reason the governance mechanisms above are not optional. A system that grows itself and cannot be audited is a system that will eventually surprise you.

## Open protocols and lock-in {#protocols}

Everything described so far has an obvious commercial hazard attached to it. A factory is a large investment, it touches every system you run, and the vendors selling pieces of it would all quite like you to buy the rest from them.

Which is why the protocol situation is worth a section, and why it is better news than it usually is at this stage of a technology.

### MCP

Model Context Protocol standardizes how an agent reaches a tool. Anthropic published it in November 2024, and it spread faster than anybody expected, mostly because it solved a problem everyone had at the same moment and the specification was small enough to implement in an afternoon.

Governance moved in December 2025, when Anthropic donated MCP to the newly formed Agentic AI Foundation, a directed fund under the Linux Foundation co-founded with Block and OpenAI, with support from Google, Microsoft, AWS, Cloudflare, and others. AGENTS.md and the goose agent framework went in at the same time. What that donation buys you is the thing that matters commercially: the protocol your integrations are written against is not owned by a company whose model you might want to stop using.

### A2A

Agent2Agent standardizes how agents talk to each other across organizational and vendor boundaries. Google announced it in April 2025 and donated it to the Linux Foundation that June. Version 1.0.0 landed in January 2026, which moved it from experimental to production-ready and added signed Agent Cards, so an agent's advertised capabilities can be cryptographically verified rather than taken on trust. Supporting organizations passed 150 in its first year, including AWS, Cisco, IBM, Microsoft, Salesforce, SAP, and ServiceNow.

Given what I wrote at layer 5 about not composing agents, you would expect me to dismiss A2A, and I do not. Agent-to-agent communication is the wrong default *inside* a work order. Across an organizational boundary it is exactly right. Your factory needs to hand work to a vendor's agent, or accept work from a partner's, and that crossing needs a protocol with discovery, identity, and verification in it. A2A is a boundary protocol, and the mistake is using it as an internal architecture.

### ACP, and which one you mean

Two protocols carry the initials ACP and they do completely different jobs, so name them carefully in a design document.

Agent Communication Protocol came from IBM and the BeeAI project, went to the Linux Foundation, and was a REST-first, async-first standard for agents to discover and call each other. In August 2025 it merged into A2A, and BeeAI moved onto A2A. It is not evolving separately any more. Do not design against it.

Agent Client Protocol came from Zed, also in August 2025, and standardizes how a coding agent talks to an editor. JSON-RPC over stdin and stdout, close in spirit to the Language Server Protocol, and adopted by JetBrains alongside Zed. Different layer entirely: MCP connects an agent to tools, A2A connects an agent to another agent, and Agent Client Protocol connects an agent to a person's editor.

Three protocols, three boundaries, and the boundaries are the interesting part.

### What the protocols buy you

Modularity, and modularity is what makes the swap possible.

Swap the model. Your prompts move, your evaluations replay, and the tools do not notice, because a tool exposed over MCP does not know which model called it.

Swap the runtime. Agents are configuration at layer 4, so moving them is moving a prompt, a tool list, and a model name. Your connectors do not change.

Swap the tool. An MCP server for Jira and an MCP server for Linear present different tools, and the agent reads the descriptions and adapts, which is a thing agents are genuinely good at.

Cross a boundary. A2A lets a partner's agent participate without either side exposing its internals.

None of that is free, and the honest version has caveats. Protocols standardize the wire, not the semantics. Two Jira MCP servers will expose different tools with different names, and agents will behave differently against them. Vendors differentiate above the protocol, in the runtime and the interface, which is where the real switching cost accumulates. And your prompts are quietly tuned to one model's habits, so a swap is a retune rather than a flag change.

Even so, compare it to the alternative. Build against one vendor's proprietary agent API, one vendor's tool format, and one vendor's runtime, and the switching cost is a rewrite. Build against MCP and A2A and it is a migration. No lock-in to Claude, to Cursor, to Grok, to Copilot, to anyone. Design for the swap, because you will make it, probably within the year.

## Two unsolved problems {#unsolved}

Everything above this point I would defend. What follows is different. Two problems sit at the middle of this design, I have hit both of them repeatedly, and I do not have a good answer to either. Stating them plainly beats pretending the architecture handles them.

### One: matching work to agents

Work orders are not the same size. That is the whole problem, and it is bigger than it looks.

One work order says "the date on the receipt page renders in the wrong time zone". Another says "migrate the user service off the legacy session store". Both are legitimate work orders. Both have a specification, an owner, and a definition of done. One is twenty minutes and four lines. The other is three weeks and touches eleven repositories.

So: does one work order map to one agent session?

**If yes**, the model is beautifully simple. A work order arrives, a session starts, the session finishes, the work order closes. Everything traces cleanly and the lineage story from layer 1 falls out for free. It also fails on anything large, because a session has a finite context budget and a real limit on how long it can hold a coherent plan. Large work orders do not fail cleanly either. The agent works for four hours, loses the thread around hour three, and produces something that looks finished and is not.

**If no**, a large work order fans out into several sessions, and now every hard question arrives at once. Who splits it? How do the pieces stay coherent, given the layer 5 argument that sub-agents cannot see each other's assumptions? What happens when piece three reveals that the split was wrong? Who notices that piece five was never picked up?

Three answers are in circulation and each has a real failure mode.

**A person sizes the work.** Work orders arrive pre-cut to roughly session-sized, and a human does the cutting as part of writing the specification. Honest, effective, and it puts a person back in the loop at exactly the point the factory was supposed to remove them. Your throughput is now bounded by how fast people can decompose work, which for large programs is slow.

**The agent decomposes its own work.** An agent reads a large work order, writes a plan, and files the steps as child work orders it or others pick up. Attractive, because the agent understands the code and a product manager does not. Risky, because a bad decomposition is expensive and hard to spot: each child looks reasonable on its own and the set does not add up. Spec-driven development's *plan* and *tasks* stages are a structured attempt at exactly this, with the plan written down and reviewable before anything is implemented. Making the decomposition an artifact a person can approve is the best mitigation I know of, and it is still a mitigation rather than a solution.

**A planner role does it.** A dedicated agent whose only job is to turn large work orders into small ones. Cleanest separation, and it reintroduces the composition problem from layer 5 at the level of work management instead of at the level of sessions. The planner does not know what the implementer will discover.

My current preference is the second, with the plan as a reviewed artifact and a hard rule that a work order which has been decomposed twice gets a person's attention. That is where I have landed today and I have changed my mind about it twice. But I hold it loosely, and the thing that makes this properly unsolved is that the right answer shifts every time the models get better at holding long context. A rule tuned to this year's session limits will be wrong next year.

### Two: concurrency

Second problem, and this is the one that will hurt. It is close to the surface for anyone running more than about five agents on one repository.

Agents work in parallel. Agents raise pull requests. Pull requests target one trunk. You can see where this goes.

Six agents start work on Monday morning against commit `abc123`. Each opens a branch, each makes a change, each runs the tests, each goes green, each raises a pull request. Six pull requests, all based on `abc123`, all passing.

Now merge one.

Trunk moved. The other five are based on a commit that is no longer the tip. Two have textual conflicts. One has no conflict but a semantic one: it calls a function whose signature the merged change altered, so it merges cleanly and fails to compile. Two are genuinely fine. Working out which is which means rebasing all five and running the full test suite on each, and that is after one merge. Repeat five more times and you have run the suite fifteen times to land six changes.

<figure>
<svg class="diagram" viewBox="0 0 720 400" role="img" aria-labelledby="fig-conc-title">
  <title id="fig-conc-title">Six parallel pull requests all based on one commit, compared with a sequenced stack where each change is based on the one before it</title>

  <text class="t-md bold" x="14" y="20">Six agents, one trunk</text>
  <rect class="surface" x="14" y="30" width="320" height="324" rx="6"/>

  <path class="line" d="M46 316 L318 316"/>
  <text class="t-sm t-mute" x="46" y="340">main</text>
  <circle class="accent-fill" cx="74" cy="316" r="5"/>
  <text class="t-sm t-mute" x="60" y="300">abc123</text>

  <path class="line" d="M74 316 C 110 316, 110 62, 158 62"/>
  <path class="line" d="M74 316 C 110 316, 110 110, 158 110"/>
  <path class="line" d="M74 316 C 110 316, 110 158, 158 158"/>
  <path class="line" d="M74 316 C 110 316, 110 206, 158 206"/>
  <path class="line" d="M74 316 C 110 316, 110 254, 158 254"/>

  <rect class="box box-warm" x="158" y="48" width="160" height="28" rx="3"/>
  <text class="t-sm" x="170" y="67">PR #4471 &#183; green</text>
  <rect class="box box-warm" x="158" y="96" width="160" height="28" rx="3"/>
  <text class="t-sm" x="170" y="115">PR #4472 &#183; green</text>
  <rect class="box box-warm" x="158" y="144" width="160" height="28" rx="3"/>
  <text class="t-sm" x="170" y="163">PR #4473 &#183; green</text>
  <rect class="box box-warm" x="158" y="192" width="160" height="28" rx="3"/>
  <text class="t-sm" x="170" y="211">PR #4474 &#183; green</text>
  <rect class="box box-warm" x="158" y="240" width="160" height="28" rx="3"/>
  <text class="t-sm" x="170" y="259">PR #4475 &#183; green</text>

  <path class="line warn" d="M296 96 L314 124 M314 96 L296 124"/>
  <path class="line warn" d="M296 144 L314 172 M314 144 L296 172"/>
  <path class="line warn" d="M296 192 L314 220 M314 192 L296 220"/>
  <path class="line warn" d="M296 240 L314 268 M314 240 L296 268"/>

  <text class="t-sm t-mute t-mid" x="174" y="378">Merge one, and four go stale at once</text>

  <text class="t-md bold" x="386" y="20">Sequenced as a stack</text>
  <rect class="surface" x="386" y="30" width="320" height="324" rx="6"/>

  <path class="line" d="M418 316 L690 316"/>
  <text class="t-sm t-mute" x="418" y="340">main</text>
  <circle class="accent-fill" cx="446" cy="316" r="5"/>
  <text class="t-sm t-mute" x="432" y="300">abc123</text>

  <path class="line accent" d="M446 316 L446 268 L530 268"/>
  <path class="line accent" d="M530 254 L530 220"/>
  <path class="line accent" d="M530 206 L530 172"/>
  <path class="line accent" d="M530 158 L530 124"/>
  <path class="line accent" d="M530 110 L530 76"/>
  <path class="accent-fill" d="M530 220 l-4 8 l8 0 z M530 172 l-4 8 l8 0 z M530 124 l-4 8 l8 0 z M530 76 l-4 8 l8 0 z"/>

  <rect class="box box-alt" x="450" y="48" width="240" height="28" rx="3"/>
  <text class="t-sm" x="462" y="67">PR #4475 &#183; on top of #4474</text>
  <rect class="box box-alt" x="450" y="96" width="240" height="28" rx="3"/>
  <text class="t-sm" x="462" y="115">PR #4474 &#183; on top of #4473</text>
  <rect class="box box-alt" x="450" y="144" width="240" height="28" rx="3"/>
  <text class="t-sm" x="462" y="163">PR #4473 &#183; on top of #4472</text>
  <rect class="box box-alt" x="450" y="192" width="240" height="28" rx="3"/>
  <text class="t-sm" x="462" y="211">PR #4472 &#183; on top of #4471</text>
  <rect class="box box-alt" x="450" y="240" width="240" height="28" rx="3"/>
  <text class="t-sm" x="462" y="259">PR #4471 &#183; on top of main</text>

  <text class="t-sm t-mute t-mid" x="546" y="378">Each change sees the one before it</text>
</svg>
<figcaption>Left: what six agents produce by default. Right: what you get if something sequences their work before they start. Stacked diffs were invented for a different reason and this is the shape that matters here.</figcaption>
</figure>

Now scale it. Thirty agents, a hundred pull requests a day, one repository. Keeping those pull requests green becomes a full-time job for the machine and a part-time job for several people, and the time it eats is precisely the time the agents were supposed to save. The wall arrives about six weeks after things start going well, which is long enough that you have already told people it is working. Repository shape decides how hard it hits. Many small repositories conflict far less than one large one, so a company on a monorepo meets this first and meets it hardest, and a company with two hundred services may not notice for a year.

Worth being precise about why this is a new problem and not an old one with more volume. Human teams solved this socially. Six engineers on one repository talk to each other. They know Priya is in the payments module this week so they stay out of it. They break large changes into sequenced pieces because they can see the queue. Agents have none of that. They do not know what the other five are doing and nothing in the architecture tells them, because we deliberately decided at layer 5 that agents coordinate through work state rather than conversation.

### Stacked diffs are one possible answer

Which brings us to a technique invented for a completely different reason.

Stacked diffs came out of Phabricator, the review system Meta open sourced, and the workflow spread from there through Graphite, Sapling, and a handful of others. Rather than one large pull request, you produce a chain of small ones, each based on the last, each reviewed on its own. What it was built to solve is a human problem: large pull requests get slow, shallow reviews, and breaking them into a sequence of small dependent changes gets each piece a real reading.

What matters for agents is a side effect of that design. In a stack, every change is based on the change before it. Nothing is based on a commit that is about to go stale, because the stack has an order and the order is explicit. Merge from the bottom and the one above is already sitting on the merged result.

So the idea is to sequence agent work the same way. Rather than six agents all branching from `abc123`, the second agent's work is based on the first agent's branch, the third on the second, and so on. Conflicts get found when the work is being done rather than at merge time, and each agent sees the changes that came before it.

Real problems with this, none of which I can wave away. Stacks are linear and agent work is a partial order, so somebody has to invent an ordering for changes that genuinely do not depend on each other, and a bad ordering means one slow review blocks four unrelated changes. Stacks assume one author who owns the whole chain and can rebase it, which is exactly what six independent agents are not. A rejection near the bottom invalidates everything above it. And the tooling assumes a human driving it from a command line.

Other partial answers exist and are worth knowing. Merge queues serialize the landing, testing each change against the actual tip before it merges, which solves correctness at the cost of a queue that gets long. Trunk-based development with very small changes shrinks the window in which a conflict can form. Ownership partitioning gives each agent a region of the codebase and keeps them apart, which works right up until a change crosses a boundary, and the interesting changes always do. Optimistic merging with fast reverts accepts some breakage and makes recovery cheap.

Every one of those is a trade, none of them is a solution, and the combination that works is going to depend on your repository, your test suite, and how brave you are. What I would say with confidence is that this is where the next few years of real engineering work goes. The agent part of an agentic software factory is close to solved. Landing a hundred concurrent changes a day on one trunk without either serializing everything or breaking everything is not.

If you are picking a problem to work on, pick that one.

## The agents are the least interesting part {#close}

Back to the definition, which has not changed since the top of the page.

<div class="key">
<p>An agentic software factory is a system that takes in specifications and produces working software, where AI agents do the execution and people decide what to build.</p>
</div>

Notice what the definition does not say. It does not say a person checks the work. Verification is the system's job: specifications written so they can be executed, tests the agent wrote and ran, mechanical checks that block on failure, policy as code, and a canary that rolls itself back when the numbers move the wrong way. People sit where rollback does not help, and that list is short and written down deliberately. The dial goes to zero, and the factory has to be built as though it will.

Six layers make that happen. An interface that leads with the questions an agent cannot answer and shows finished artifacts rather than transcripts. Agents that are roles with prompts and tools, doing one work order each, not composed into graphs. A runtime that keeps the loop outside the sandbox so that failures are survivable and the model stays a component you can swap. Routing that turns events into work by what they mean and which role should handle them, with a gateway making tool access something you can govern in one place. Connectors that give agents a real identity in every system they touch. And underneath, registries, workspaces, sandboxes, and a lineage record that can walk from any artifact back to the person who asked for it.

Underneath all of it is one idea, and it is the one worth carrying away. The interesting object is the work order. Everything in the factory exists to move work orders through states and produce artifacts from them. Which model is running, how many agents there are, whose product they came from: all of it is an implementation detail of the station, and stations get re-equipped.

A factory built around work orders survives the model changing, which it will, twice a year, for the foreseeable future. A factory built around a particular agent architecture gets rebuilt every time the models improve enough to make the architecture unnecessary. Plenty of clever agent scaffolding from 2024 is already dead weight, and the scaffolding being built right now will go the same way.

Two problems remain genuinely open: how to match work of wildly different sizes to sessions, and how to land a hundred concurrent changes a day on one trunk. Neither is an agent problem. Both are work management problems, which is the point.

If I were starting again on Monday, I would build the work management first and the agents last. I did it the other way around, because the agents are the fun part and watching one work for the first time is genuinely startling. Nearly everything I have thrown away in two years was agent scaffolding. Almost nothing I have thrown away was work management. The parts that survived are the boring ones: a record of what state a piece of work is in, a question with two options and a recommendation, a written list of the things that cannot be undone.

Build it or buy it. Either way, look for the work order first. If the demo opens on a chat window and never shows you a work item, a state, or an artifact, you are looking at a very good tool and not at a factory. The agents are the least interesting part, and I say that having spent two years finding it out the slow way.

<hr>

### References

<ul class="refs">
<li><a href="https://www.anthropic.com/engineering/managed-agents">Scaling Managed Agents: Decoupling the brain from the hands</a>, Anthropic. The session, harness, and sandbox split, and the latency, resilience, and security arguments for it.</li>
<li><a href="https://cognition.com/blog/dont-build-multi-agents">Don't Build Multi-Agents</a>, Walden Yan, Cognition. The context-fragmentation argument against composing agents.</li>
<li><a href="https://www.anthropic.com/engineering/built-multi-agent-research-system">How we built our multi-agent research system</a>, Anthropic. The counter-case, where parallel read-only sub-agents outperform a single agent.</li>
<li><a href="https://github.com/github/spec-kit">GitHub Spec Kit</a> and its <a href="https://github.github.com/spec-kit/">documentation</a>. Spec-driven development as specify, plan, tasks, implement, converge.</li>
<li><a href="https://blog.modelcontextprotocol.io/posts/2025-12-09-mcp-joins-agentic-ai-foundation/">MCP joins the Agentic AI Foundation</a> and the <a href="https://www.linuxfoundation.org/press/linux-foundation-announces-the-formation-of-the-agentic-ai-foundation">Linux Foundation announcement</a>, December 2025.</li>
<li><a href="https://www.linuxfoundation.org/press/a2a-protocol-surpasses-150-organizations-lands-in-major-cloud-platforms-and-sees-enterprise-production-use-in-first-year">A2A at one year</a>, Linux Foundation, and the <a href="https://github.com/a2aproject/A2A">protocol repository</a>.</li>
<li><a href="https://agentcommunicationprotocol.dev/">Agent Communication Protocol</a>, which merged into A2A in August 2025, and <a href="https://agentclientprotocol.com/">Agent Client Protocol</a> from Zed, which did not.</li>
<li><a href="https://github.com/IBM/mcp-context-forge">ContextForge</a>, IBM's open source gateway for MCP, A2A, and REST services.</li>
<li><a href="https://newsletter.pragmaticengineer.com/p/stacked-diffs">Stacked Diffs (and why you should know about them)</a>, The Pragmatic Engineer, and <a href="https://jg.gg/2018/09/29/stacked-diffs-versus-pull-requests/">Stacked Diffs Versus Pull Requests</a>, Jackson Gabbard, on the Phabricator workflow and why it exists.</li>
</ul>
