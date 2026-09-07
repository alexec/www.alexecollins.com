---
title: I wrote a book for one person
date: 2026-09-07 12:00 UTC
tags: claude-code, books, ai
published: true
---
![How to Build a Universe, printed, next to the companion app on an iPad](/images/i-wrote-a-book-for-one-person/book-photo.jpg)

About ten years ago I wrote a book for Manning, on Selenium. It took me something like a hundred hours, most of them evenings and weekends. That book was written the way books have always been written: by one person, for as many readers as possible, because a publisher, an editor and a print run all have to be paid for, and the only way to pay for them is to sell a lot of copies.

I had a hunch that this is no longer the only way. Every step that used to need a publisher is now cheap. You can lay out the scaffolding of a book, hand the writing to Claude, have it design the cover, upload a PDF to an online printer, and a real book turns up in the post. None of that was possible ten or fifteen years ago. And if it works, you no longer have to write for everyone. You can write a book for one person.

So I tested it. I wrote a popular science book for my nephew.

## The book

It's called *How to Build a Universe*, and the cover says "a book for my nephew" underneath, because that's what it is. It's aimed at readers of ten and up. The idea running through it is that everything is made of something else, so the book is a ladder, and maths is the floor. Physics, energy, entropy, atoms and information sit on top of that; stars, chemistry and planets on top of those; then life, animals, people and fire, and after fire the things we made up that became real, which is language, culture, settlement, money, law and companies. The last rungs are electricity, computers and AI. Twenty-three in all, with twenty-six short interludes between them about things people built on the way up (music, cooking, that sort of thing), and it runs to 448 pages, which is more than I expected when I started.

Every chapter has the same shape, which I settled on before a single chapter was written, and that turned out to be the most important decision in the whole project.

![The eight beats every chapter follows](/images/i-wrote-a-book-for-one-person/chapter-template.svg)

Not every beat earned its place. "The bit worth telling someone" was meant to give each chapter one boxed idea a ten year old could retell at dinner, and on the page it reads like homework, so I cut it for the second edition. What I did like, and kept, were the personal historical stories: Euclid handing you a list of every prime and then multiplying them together to prove the list is wrong, Maxwell's demon sorting molecules, that kind of thing. A ten year old will follow a person doing something long after they've stopped following an idea.

## How it got made

I didn't write the sentences. I wrote the shape of the book: the chapter list, what each chapter had to cover, the template above, the reading age, and the art direction. Then I set up four Claude agents, each with a narrow brief.

![The four agents and the human sign-off loop](/images/i-wrote-a-book-for-one-person/writing-process.svg)

The Author writes the chapter, with the template and the brief and nothing else in front of it. It also scores its own prose with reading-level tools and revises until it hits the target, which was more useful than I expected, because reading level is exactly the kind of thing I can feel but can't measure.

The Copy Editor reads the draft and pushes it toward plain sentences a ten year old would want to read. The Editor reads the book so far and checks that the argument holds, and in particular that nothing gets used before it's been explained. The Artist made the cover and the illustrations, and it ran alongside the writing rather than inside the loop.

Then I read the chapter and either signed it off or sent it back with a note; nothing shipped without that.

I set two rules at the start. Nothing could appear before the thing it's made of, so a chapter couldn't mention atoms until atoms had a chapter. And anywhere the book was making a choice rather than stating a fact, it had to say so. The first rule was harder to keep than I expected: gravity got used before it was explained, E = mc² turned up out of nowhere, and Chapter Four described a demon sorting molecules two chapters before molecules existed. I caught those by hand, and after a while I had Claude write a small script that checks for them after every chapter, because catching them by luck wasn't working.

## The scripts

A fair amount of the work wasn't prose at all, and I'd have struggled without it. There was a script to score the reading level of a chapter, which the Author ran on its own drafts and revised against. There was the dependency checker above, which reads every chapter and flags anything mentioned before its own chapter exists. And there was the printer. I uploaded the PDF to an online print-on-demand site, it came back with a list of what was wrong (bleed, margins, fonts not embedded, that sort of thing), and I pasted the list into Claude, which fixed the PDF. Two or three rounds of that and it was accepted. None of these were clever, and none took more than a few minutes to write, but each one replaced a job I'd otherwise have done badly by eye.

## What was hard

Getting the structure of each chapter right, because that's where the book actually gets written. Give the Author a vague brief and you get a vague chapter, and no amount of editing rescues it. There were a few chapters I read and couldn't tell what the point was, and every time the fault was upstream, in my brief.

Review was the other hard part. I spent far more time reading than writing, most of it nudging the prose toward something a human would say. By the fifth or sixth pass on the same chapter I couldn't judge it any more. It's a kind of snow blindness: you've read the words so many times you can't tell whether they're good. At that point you need a fresh reviewer, and another Claude isn't quite enough, because it shares your blind spots. Next time I'd hand a few chapters to a person who hasn't seen them.

## What was easy

The cover, for one. Claude produced dozens of variations and I picked one, in less time than choosing a font used to take.

Printing, too. Once the printer's checks passed, a week or so later a proper paperback arrived. Holding a book you didn't type a word of, with a cover you didn't draw, that is nonetheless entirely yours, is an odd feeling and I recommend it.

I also had Claude build a companion app, which is the thing on the iPad in the photo. The idea was a small game for every chapter, twenty-three of them, so you'd play your way up the ladder. It didn't work. The games were boring, I didn't want to play them, and a game you have to be talked into playing is worse than no game. Making twenty-three of them good would mean designing twenty-three of them myself, and I'm not going to do that. So the app exists, and it isn't the point.

## The numbers

![Hours spent writing each book](/images/i-wrote-a-book-for-one-person/time-comparison.svg)

Around a hundred hours of my time went into the Manning book. This one took somewhere between ten and fifteen, and a lot of that overlapped with other things. I'd set the Author off on a chapter, go and do something else, and come back when the Copy Editor and Editor had finished with it. What I spent was reading time, not typing time.

## Did it work?

Mostly. I wouldn't change the process. Writing to a formula, one chapter template filled in twenty-six times, suits an educational book very well. I doubt it would suit fiction, and I'm not claiming it does.

Two things I'd do differently. I'd bring in a human reviewer once I go snow blind, as above. And I'd give the Copy Editor an anti-AI-slop skill: a list of the words, phrases and tics that mark prose as machine written, so it strips them out rather than relying on me to spot them on the sixth read. I didn't have one for this book. I'd want one for the next.

One big caveat: my nephew hasn't read it yet. The whole point of a book for one person is what that one person makes of it, and I don't have that data. I need to get the book to him. When I do, I'll write up what he thought, and that will be the real test.

## Why this matters

For as long as there have been publishers, the cost of making a book has pushed every book toward the widest audience it could find. That pressure is gone. You can write a book for your nephew, or your team, or one customer, or yourself, in the time it takes to read it carefully a few times.

I think that's a new kind of book, one with the structure and weight of a book but addressed the way a letter is addressed. I don't know yet what people will do with that. I only know it's now possible, because there's one on my desk.
