---
title: Every event is a markdown file
date: 2026-10-06 15:00 UTC
tags: ai, architecture, oped
published: true
---
People keep telling me the next big thing in AI is event-driven agentic workflows. I agree with them. I also think most of them are picturing something too small: a webhook that starts an agent, which is a weekend project.

Here's the bigger version. Everything in the software ecosystem becomes an event. Agents can only use those events if they all arrive in one shape, and that shape is markdown. So the workflows that react to events are markdown files too, with front matter saying when they fire and what they target. That front matter is a standard nobody has written yet.

None of the hard parts are new, either. Debouncing, deduplication, retries, correlation, dead letters: integration engineers named all of them twenty years ago. Event-driven agents are enterprise integration patterns applied to a new kind of consumer, and the interesting part is the handful of places where that consumer breaks the old patterns.

This follows on from [The Agentic Software Factory](/the-agentic-software-factory), which called event routing the conveyor belt and gave it one section. It deserves more than that.

## Everything is an event {#events}

Start with the obvious ones. A pull request is opened. A pull request is merged. A ticket moves to done. Somebody replies in a Slack thread. A build fails.

Then the ones people don't count. I sit down at my laptop. I walk away from it. The Mac goes idle. It's 02:00.

Presence events matter as much as code events, and they're the ones nobody wires up. Me arriving at a computer is the right moment for the three questions my agents raised overnight to reach me. A machine going idle is spare capacity for a long build or a nightly maintenance run. Me leaving is a sign that anything needing my answer in the next hour should go to my phone instead.

Once agents do the work, anything that changes in the world is a possible reason to start work. That turns a software organization into a very large stream of events, and the question becomes what shape they arrive in.

## Agents need one shape {#shape}

Every source has its own payload. A GitHub webhook is a JSON blob with an event type, a repository, a branch, a commit, an author, and forty fields nobody needs. A Jira transition looks nothing like it. A Slack event looks nothing like either. Presence and idle events don't have a payload format at all, because until now nothing has wanted them.

An agent can't do much with forty fields. In the factory, the router's job was to take a system message and turn it into a prompt. "A commit landed on `feature/retry-policy` for work order W-4471 in the payments project. Here is the work order, here is the design, here is the diff." That's a translation from many shapes into one, and today every team building agents writes its own.

It has a name. Gregor Hohpe and Bobby Woolf's *Enterprise Integration Patterns* (2003) calls it a Normalizer, and the one shape it normalizes into a Canonical Data Model. Anybody who lived through the SOA years will wince at that second name. Canonical data models got a bad reputation because every consumer was strict code, so the model had to describe everything precisely, and it grew into an XML schema that a committee owned and nobody could change.

This time it's different, because the consumer reads prose. An agent doesn't need a field for every fact. It needs a few fields to decide whether to act, and a paragraph that explains what happened. The canonical model can stay loose, and that's what makes it workable.

## That shape is markdown {#markdown}

Markdown is what agents already read and write. It's what people read. It diffs, it versions, and it lives in a repository next to the code.

The industry has already settled on it for everything around agents. `AGENTS.md` and `CLAUDE.md` hold a project's instructions. Skills are a `SKILL.md` with front matter. Spec Kit writes specifications, plans and task lists as markdown in the repository. Each time, the choice was between a structured format that machines liked and a prose format that models liked, and each time markdown with front matter won, because it gives you both.

Events are the next thing to follow. The front matter is for the router, which needs fields it can filter on. The body is for the agent, which needs to understand what happened.

```markdown
---
type: pull_request.merged
source: github
topic: github:acme/payments
subject: github:acme/payments/pull/4471
actor: alex
time: 2026-10-06T09:12:00Z
---
Pull request #4471, "Retry failed payments once", was merged into main by Alex.
It belongs to work order W-4471. Three files changed and the tests are green.
```

There's prior art for the envelope. [CloudEvents](https://cloudevents.io), a CNCF specification, already standardizes `type`, `source`, `subject` and `time` for events in general, in JSON. I'd keep those attribute names exactly and put them in front matter, then add the one thing CloudEvents never needed: a body written for a model.

## Workflows are markdown too {#workflows}

If events are markdown, the workflow that reacts to one should be markdown as well. Front matter says when it fires. The body is the prompt.

```markdown
---
on: pull_request.changes_requested
filter:
  topic: github:acme/payments
  labels: [agent]
target: subject
role: coding-agent
cooldown: 10m
concurrency: 1 per subject
tools: [github, tests]
owner: alex
---
Somebody asked for changes on {{subject}}. Read the unresolved review comments,
make the changes, run the tests and push to the same branch. If a comment asks
for something the work order doesn't cover, ask Alex instead of guessing.
```

A workflow is a prompt with a trigger stapled to the top. Anybody who can write a prompt can write one, which matters, because the people who know which workflows a project needs are the people on that project, not the platform team.

The same shape covers the events nobody wires up today. A nightly maintenance run is `on: schedule` with a cron expression. Delivering questions when I sit down is `on: human.arrived`, targeted at me, with a body that says to send the oldest blocking question first. Running the slow test suite when a build machine has been idle for twenty minutes is `on: host.idle` with a filter on how long.

None of this needs a new language. It's a file, so it can be listed, searched, versioned, reviewed and approved. An agent can write one, which turns out to matter a great deal, and I'll come back to it.

## Topics and instances {#targets}

Most of the routing comes down to one distinction: what the workflow is aimed at.

A **topic** is a place things happen. A project, a repository, a Slack channel, a Jira board. Workflows aimed at a topic react to anything in it: every merged pull request in the payments repository, every new ticket on the board.

An **instance** is one thing. An issue, a pull request, a Jira ticket, a Slack message, a Slack thread. Workflows aimed at an instance follow that one thing through its life: when this pull request gets changes requested, when this thread gets a reply, when this ticket is unblocked.

Every source has both, and they line up surprisingly well. A repository holds pull requests, a board holds tickets, a channel holds threads. Give each one an identifier in a common form (`github:acme/payments/pull/4471`, `jira:PAY-212`, `slack:#payments/1696583520.1234`) and a workflow can say what it targets without caring which system it lives in.

The event types line up too. A short shared list covers most of it: opened, updated, commented, merged, closed, arrived, left, idle, scheduled. Each source adds its own specific types under that list. A workflow that wants every closed thing across GitHub, Jira and Linear subscribes to `closed`. A workflow that cares about GitHub review states subscribes to `pull_request.changes_requested`.

## The trigger is the easy part {#scars}

Once you have a shape for events and a shape for workflows, getting an event to start an agent is the easy part. Everything that hurts comes after that, and each field in that front matter exists because of something that breaks without it.

What surprised me, writing them down, is that almost every one already has a name in *Enterprise Integration Patterns*. Integration engineers solved most of this for message buses two decades ago. Agent builders, me included, are learning it again one incident at a time.

| Field or behaviour | What breaks without it | The pattern |
|---|---|---|
| `filter`, `labels` | Every event wakes every workflow | Message Filter |
| `on` and `role` | Routing to a session orphans events when the session dies | Content-Based Router |
| `subject` | Nothing ties an event back to its work order | Correlation Identifier |
| `cooldown` | Ten pushes in a minute start ten sessions | Aggregator, or a debounce |
| a deduplication key | A redelivered event starts a second agent | Idempotent Receiver |
| `concurrency` | Two agents claim the same task | Competing Consumers |
| merge ordering | Six green pull requests go stale after one merges | Resequencer |
| a separate `failed` type | "Done" quietly includes the failures | Dead Letter Channel |
| holding questions for `human.arrived` | Questions sit in a log nobody reads | Durable Subscriber |
| the diff passed by reference | Events too large for a context window | Claim Check |
| the work order's states | Nobody knows where a piece of work is | Process Manager |
| an audit log in the gateway | Nobody can say who dropped the table | Wire Tap |
| a workflow registry with owners | Fifty workflows nobody remembers writing | Control Bus |

A few of these have stories behind them.

**Route to a role and an instance, never a session.** The obvious design is to wake the session that raised a pull request when something happens to it. It breaks within a week. Sessions end, run out of context, die with their sandbox, and belong to a model you've since upgraded. Each of those turns a real event into an orphan with nowhere to go. Route on what the event means and which role should handle it. Changes requested goes to the coding agent and changes made goes to the reviewer, whichever session happens to exist. The pull request remembers. The session doesn't have to.

**Competing consumers need a counter.** Two agents read the same task file a second apart, and both decided the task was theirs. Numbering broke the same way. Each agent took the highest task number and added one, and three different tasks ended up numbered T601. The fix for both is boring: claim things atomically, and hand out identifiers from a counter rather than working them out. The leases that worked best were made with `mkdir`. It's atomic, it works when the control plane is down, and a person can inspect it with `ls`.

**The Durable Subscriber is a person.** An agent that asks a question into its own log hasn't asked anybody anything. The question has to leave the agent and wait somewhere durable until the person turns up, which is exactly what `human.arrived` is for. My first design let agents ask open questions, and they arrived as a pile of things to think about. Turning each one into two or three options with a recommendation turned a decision into a tap. The answer is an event as well. It targets the blocked work order and starts the work again without anybody going back to move a ticket.

**"Done" will lie to you.** Finished-and-worked and finished-and-failed are different facts. Report them as one event and every workflow downstream of "done" inherits the mistake. You'll see a 94% completion rate while a third of the work failed. Failure needs its own event type, with the reason written in words, next to the work order.

**The workflow registry is a cron table.** A workflow that fires on an event and runs an agent with tools is a program with a trigger. Treat the registry the way you'd treat a cron table on a production host, because that's what it is. The failure isn't dramatic. It's fifty workflows nobody remembers writing, four of which fire every night and cost money, and one of which has been failing quietly since March. Every workflow needs an owner in its front matter.

## Where agents break the patterns {#different}

If that table were the whole story, this would be a short post recommending a book. Agents are a new kind of consumer, and they break the old patterns in four places. That's where the real work is.

**The receiver isn't deterministic.** The Idempotent Receiver assumes that processing a message twice does the same thing twice, so a duplicate is harmless as long as you notice it. An agent given the same event twice does something different the second time. It takes another approach, opens a second pull request, or leaves a second review that disagrees with the first. Deduplication has to happen before the agent starts, not inside it, and anything the agent does that can't safely happen twice has to be keyed on the work order rather than the session. Agents that run with nobody watching should stick to things that can be undone. The things that can't (deleting data, moving money, messaging everybody, rewriting published history) go on a list somebody writes down on purpose.

**The consumer reads prose.** I covered this above, and it's good news. It's the reason a canonical model can work this time. Keep the structured fields to the minimum a router needs and let the body carry the rest.

**A consumer can create consumers.** No message bus ever had a subscriber that wrote new subscriptions. Agents do. An agent that notices it has done the same thing eleven times can propose a workflow that does it, and that's one of the most useful things a factory does. It's also how permissions leak. I watched an agent get refused an action, start a helper that wasn't gated the same way, and have the helper do it. Nobody involved felt they were cheating. The agent was told to get something done and it found a route. A permission an agent can widen by starting another agent isn't a permission. The fix is a `tools` allowlist in the workflow's front matter, capped by what the workflow's author could do, and enforced in the gateway rather than the prompt. *Enterprise Integration Patterns* has no pattern for this, because it never needed one.

**One endpoint is a person.** An escalation is request and reply, a pattern as old as messaging. In this case the reply might take a day, come from a phone, and depend on whether the person is at their desk. That's why presence belongs in the event stream. A system that knows when I sit down can hold a question until then. A system that doesn't either interrupts me at dinner or waits until I happen to look.

## The standard nobody has written {#standard}

Pieces of this exist. CloudEvents standardizes the envelope. GitHub Next's [Agentic Workflows](https://githubnext.com/projects/agentic-workflows/) already write workflows as markdown files with front matter triggers, which I take as a good sign that the shape is right. But they only cover events from GitHub. Nobody has a shared format that covers a pull request, a Jira ticket, a Slack thread and a person sitting down at a laptop, with the same targets, the same event types and the same fields for cooldown, concurrency and tools.

That's the gap. Whoever fills it will do for agent workflows what `AGENTS.md` did for agent instructions. It's a small, boring file convention that everybody adopts because it's easier than inventing their own.

So yes, event-driven agents are where this is going. What's missing is agreement on the shape: events as markdown, workflows as markdown, and front matter as the contract between them. Before you build an agent router, read *Enterprise Integration Patterns*. Most of the answers are in it. The four places where agents break those patterns are where the work is.

And if a demo shows you an event starting an agent, ask what happens when the same event arrives twice.
