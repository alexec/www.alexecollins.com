---
title: Brushwise, and the day it contradicted itself
date: 2026-09-15 12:00 UTC
tags: ios, claude-code, health
published: true
---
Brushwise went on sale at 1:06 this morning while I was asleep. Nobody pressed a button. I'd set it to release on approval, so App Review finished and the store put it up on its own. It's [free, on the iPhone](https://apps.apple.com/gb/app/brushwise/id6809011641), and it walks you through a full oral-hygiene routine: water flosser, floss, a real two-minute brush including your tongue, then mouthwash, with a toothbrush check once a week.

[![Brushwise counting down the first quadrant of a two-minute brush, with a sourced tip underneath](/images/brushwise-and-the-day-it-contradicted-itself/brushwise.jpg)](/images/brushwise-and-the-day-it-contradicted-itself/brushwise-full.jpg)

*Thirty seconds a quadrant, and advice that knows where it came from. Click for the full-size version.*

Call it app 2/n in [the series I started last week](/building-ios-apps-in-2026), after [Corpospeak](/corpospeak-my-first-app-on-the-app-store). First commit on 5 September, on sale on the 15th, 120 commits in between.

## The timer is the boring part

Counting to two minutes is a clock and a progress bar. I could have finished that on the first evening, and I nearly did.

The reason the app took another nine days is that the advice is the product. I knew the steps of a good routine and still did them badly: two minutes is much longer than it feels, flossing gets skipped when you're tired, and nobody replaces a toothbrush on schedule. What that needs isn't clever technology. It's a timer that won't let you round down, and a sentence that turns up at the moment you're about to do the thing wrong.

The moment you start writing those sentences, you're making health claims. So the app got two rules, written into the file the agent reads before it touches anything:

1. Every claim traces to a current, named source.
2. The app always says why.

There are 87 tips in there now and 40 sources behind them, each one tagged in the code with where it came from: NHS, the American Dental Association, the Oral Health Foundation, a Cochrane review, a handful of papers. I checked every specific number against the thing it came from rather than inventing one. That sounds obvious. It is also the part an agent will quietly get wrong if you let it, because a plausible number is much easier to write than a sourced one.

## The day it contradicted itself

On 8 September the app told you, correctly and with a citation, not to use mouthwash straight after brushing, because you rinse off the concentrated fluoride the toothpaste leaves behind. That's the NHS line, reviewed last June. Then it walked you through exactly that, with mouthwash as the final stage.

The advice was right. The routine was not. So brushing moved to last, and the routine ended on "spit, don't rinse".

I reversed that the next day and put mouthwash back at the end.

What carries the reversal is one narrow result. Duckworth, *Caries Res* 2009: rinsing with a *fluoride* mouthwash after brushing left salivary fluoride significantly higher than brushing alone, not lower. A fluoride rinse doesn't undo the brush.

That result is narrow, so the advice had to get narrow with it. The mouthwash tips now say the rinse has to contain fluoride, that plain water would wash the fluoride off, and that a separate time of day is better still. The brush stage's "spit, don't rinse" became "don't rinse with water", which is what the source actually says.

What happened next is the part I'd hand to anyone building something health-adjacent. There is a test in the repo that reads the mouthwash tips and fails if any of those three qualifications goes missing. Not a comment, not a note in a document nobody opens. A test. If someone tidies that copy up in six months, the build breaks, and the choice in front of them is to put the qualification back or put brushing back last.

Blanket public advice and a specific result disagreed, and I went with the specific one. That's defensible exactly as long as the app keeps saying the narrow thing. You don't manage that by remembering. You manage it by making forgetting break the build.

## An app about brushing your teeth is rated 13+

Not 4+, which is what I assumed when I opened the questionnaire.

Two answers get it there on their own. The tips name smoking, nicotine and alcohol, which is an infrequent alcohol-and-tobacco reference. And telling you what to do about bleeding gums is treatment information. Editing the smoking tips out would buy nothing, because the medical answer still lands on 13+.

So I answered honestly and took the rating. It's a comic result for an app whose main job is to count to thirty four times. It's also a reminder that the questionnaire asks about the words in your app, not about who you pictured using it.

## I sold a feature I never built

The App Store description offered you "quiet, one of your own playlists, or a built-in soundscape" to brush along to. There is no playlist. Nothing in the app imports MediaPlayer or goes anywhere near your music library, and the privacy policy says so in as many words. I'd written the listing against what I'd planned rather than against what was there.

An audit caught it four days before review did, along with the README and the description both describing a set of sounds the app had stopped making days earlier. Inaccurate metadata is a 2.3 rejection, and this one also contradicted my own privacy policy, which is worse.

Write the listing off the code. The code is the only document in the project that can't be out of date.

## What's in it, and what isn't

No account, no ads, no analytics, and no network connection at all. Everything stays on the phone, including the achievements, which are local rather than Game Center. If you want it to, it writes each finished routine to Apple Health as a Tooth Brushing event with its real start and end times. It only ever writes. It never reads your Health data.

The first-run sheet closes on "Private and free forever", and I'd like to go on being able to say that.

1.0.0 is what shipped, and 1.0.0 is what I'm describing. There's a list of small things for a 1.0.1, and none of them are promises.

---

[Brushwise](https://apps.apple.com/gb/app/brushwise/id6809011641) is free on the App Store. iPhone, iOS 17 or later. The [privacy policy](/brushwise/privacy.html) and [support page](/brushwise/support.html) are here on the site.

Brushwise offers general guidance based on public advice from dental bodies. It is not a substitute for advice from your own dentist or hygienist.

*Co-authored by Claude. Claude wrote the app's code and helped write this post from the project's own notes. The arguments, the judgements and the mistakes are mine.*
