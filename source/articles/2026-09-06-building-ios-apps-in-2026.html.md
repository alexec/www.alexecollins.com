---
title: Building iOS apps in 2026
date: 2026-09-06 12:00 UTC
tags: ios, claude-code
published: true
---
Confession time: despite spending the last twenty years deep in backend infrastructure—wrangling workflow engines, Kubernetes, and distributed systems from my home office here in Walnut Creek—until this summer, I had never actually shipped an iOS app. I don't know Swift, and I've never touched UIKit. Aside from a couple of toy macOS apps I hand-coded years ago, mobile development was completely outside my wheelhouse.

But since June, that changed. I've built a handful of native Apple apps. I shipped a few, and intentionally tossed the rest. This series is about what that experience actually looked like. This first post lays out the "why," and the ones that follow will dive into specific case studies.

![Equilibrium, a Mac app showing hours worked per day as a column for each day](/images/building-ios-apps-in-2026/equilibrium.png)

*Equilibrium, a Mac app that works out how many hours I've worked from when the laptop was awake. An app for exactly one user.*

## The argument

So, why now? I think two massive shifts happened at exactly the same time.

First, coding agents finally crossed the threshold from "helpful assistant" to "capable of doing the heavy lifting." (As someone who geeks out over agentic systems and tools like the Claude ADK, I was eager to put this to the test). Second, Apple started baking genuinely useful AI directly into the operating system—and handing it to developers for free.

Combine those two, and suddenly, building small, highly personal apps that never would have justified the time investment before just makes perfectly logical sense. I don't think I'm the only one seeing this. Apple added agentic coding to Xcode 26.3 back in February, and I've read reports that new App Store submissions rose 84 percent year-over-year in the first quarter, though I can't tell you how much of that is cause and effect. Either way, this post isn't about the market; it's about what the process was like for me.

## How I worked

Here's the wild part: I didn't actually write the code.

Instead, I handed Claude Code the keys to my MacBook, Xcode, a browser, and my Apple developer account. Claude wrote the Swift, built the projects, fired up the simulator, pushed the builds to my devices, and even wrangled the App Store Connect forms. When it needed a third-party account, it just opened a browser and signed up. My role shifted entirely. I acted as a reviewer and product manager—describing what I wanted, providing the tools, and evaluating the output.

[![Claude Code on the left, the iPhone simulator running Brushwise on the right](/images/building-ios-apps-in-2026/claude-code-and-simulator.png)](/images/building-ios-apps-in-2026/claude-code-and-simulator-full.png)

*Claude Code and the iPhone simulator running Brushwise, side by side. Click for the full-size version.*

I realize trusting the output blindly sounds reckless, especially for someone whose career has involved rigorously reviewing pull requests. I haven't read most of the code it generated, and I probably never will. But with mobile apps, the feedback loop is visceral: it either works on my phone, or it doesn't. The cost of building a native app now basically boils down to how clearly you can describe it and how honestly you can test it.

What I found is that the agent is brilliant at writing code, mediocre at configuration, and completely useless the second a human needs to authenticate or click something. Code signing, certificates, and passwords? That all came back to my desk.

## What went wrong

Of course, I messed up plenty. My biggest rookie mistake was aiming too high out of the gate. Every time I pitched a massive idea, I'd get an app that *looked* functional but was essentially a Hollywood set—buttons in the right places, smooth navigation, but structurally hollow behind the scenes. The fix was always the same: strip it back to square one, pick one hyper-specific feature, nail it, and then expand.

I found the same rule applies to platforms. iOS, iPadOS, and macOS all have their own quirks. Asking an agent to support all three simultaneously usually resulted in an app that ran poorly on all of them. Pick one, get it right, then port.

Eventually, I started viewing those broken early versions as rapid prototyping rather than wasted effort. When an app only costs you an afternoon to build, throwing it away is liberating. The digital wreckage told me which ideas were viable much faster than traditional planning ever could have. Two of my apps died this way, and I was glad to find out early.

## What Apple gives you

As for Apple's native tools, it was a mixed bag.

The on-device model honestly underwhelmed me. Apple's documentation puts its context window at around 4,000 tokens, and in practice it just can't chew through large or complex text. It was fine for quick summaries or rewrites, but the more I gave it, the more it misunderstood me. I'm holding out hope for Private Cloud Compute in iOS 27 to handle the heavier lifting, and I'm very curious to see if tool calling will be practical there.

The real headache, though, was evaluation. You can't confidently ship an AI feature without solid evals. Claude was great at writing the tests, and they always passed. But the moment the feature hit real-world data, it stumbled. Real data is messy. If you're extracting actions from meeting notes, you need to account for wildly different conversation styles, varying numbers of speakers, and different transcription formats. Sourcing that varied data is the actual hard part now, not the coding.

On the bright side, speech transcription is vastly improved. You get two models now. In my use, the older one is fast but rough, and the newer one is slow but far more accurate. I ended up using both in tandem—flashing the fast one on screen so the user feels heard immediately, while the slow one quietly generates the permanent transcript. I'll show exactly how that works in one of the case studies.

I also played around with Personal Voice. The stock text-to-speech voices are still pretty lackluster (somehow worse than Siri), so having the app speak in my own recorded voice was a fun alternative. People ask why I went through the hassle instead of using a built-in voice, and honestly, there's just something uniquely fascinating about hearing your own voice say things you never actually said.

![Corpospeak rewriting "Can we push the deadline? I am completely swamped." as corporate jargon, with Personal Voice selected](/images/building-ios-apps-in-2026/corpospeak.png)

*Corpospeak: say it plainly, hear it back as corporate jargon, in your own voice.*

Then there's ARKit. It's incredible at mapping flat surfaces, but it was easily the most frustrating feature to build with an AI agent. Why? Because Claude can't hold a phone up to a wall to see if the virtual overlay actually stuck to the right spot. I spent hours acting as its eyes, constantly typing, "Nope, that doesn't work, fix it." To make matters worse, I eventually realized a feature I was relying on required LiDAR—and the iPad I was testing on didn't have it.

## Where the limit is

For me, the limit of agentic coding turned out to be the physical world.

If Claude can run the test itself—like checking a timer or verifying a text rewrite—the loop works beautifully. But the second a feature touches reality, physical spaces, or real human voices, you still need a human in the loop to test it. I don't see that changing. What I expect to change are the models. My guess is that the stuff breaking on our phones today will work in six months, either on-device or routed through Private Cloud Compute.

## The catch

So, here's the catch: building got cheap. Everything *after* building didn't.

I haven't measured any of this myself, but from what I've read, the same tools that let me ship so quickly are flooding the App Store, review times are growing, and AI apps churn faster than ordinary ones. If your goal is to chase subscriptions and fight for the top ten percent, code creation was probably never your biggest bottleneck anyway.

To me, the truly exciting space is much smaller. It's building hyper-custom apps for yourself, your family, or a niche you already know inside and out. In that world, App Store discovery doesn't matter because you already know exactly who the users are.

<img src="/images/building-ios-apps-in-2026/brushwise.png" width="360" alt="Brushwise guiding a two-minute brush, upper right quadrant, with a countdown and a tip">

*Brushwise, a guided tooth-brushing routine. Nobody is getting rich on this, and that is fine.*

That is where this series lives.

**Next post:** The first case study.
