---
title: The vision model I can't ship
date: 2026-09-11 12:00 UTC
tags: ios, claude-code, ai
published: true
---
There's a plush octopus in a bobble hat sitting on my desk. I pointed my phone at it, pressed the shutter, and the phone said: "a plush toy of an orange octopus wearing a blue and black striped hat and scarf, holding a white ball, and has the word INTUIT on its tag."

It read INTUIT off a little cloth tag. That took one second, with the phone in aeroplane mode. No server, no API key, nothing left the device.

[![Three vision models describing the same photograph of a plush octopus toy](/images/the-vision-model-i-cant-ship/three-models.jpg)](/images/the-vision-model-i-cant-ship/three-models-full.jpg)

*Three models, one photograph, on an iPhone 15 Pro Max. Click for the full-size version.*

Then I read the licence, and found out I'm not allowed to use it. This is the case study about that.

## Why I wanted this

Two of my apps have a camera in them and a blank text field right next to it. Rehang lets you arrange pictures on a wall in AR before you drill any holes, and it calls each one "Piece 1" and "Piece 2" until you name it yourself. What's Where? photographs your cupboards so you can prove what you owned when the insurance company asks.

In both cases there's a photo, and there's a gap where a description should be, and I've been filling that gap by typing. So the question I actually wanted answered was narrow: can a phone look at a photograph and tell me what's in it, well enough to save me the typing?

I built a throwaway app to find out. Camera, shutter, words on screen, nothing else. No settings, no history, no sharing. It exists to produce an answer and then be deleted.

## What's actually in the box

Apple published FastVLM last year and it gets described as a Core ML model. That's half true, and the half matters.

It's two models sharing a folder. The eye is FastViTHD, a vision encoder that ships as a Core ML package, 482 MB of it. The mouth is a Qwen2 0.5B language model that runs on MLX, on the GPU, another 1.2 GB. Apple hands you both halves in one zip, and your app carries the lot, which comes to 1.7 GB sitting in the bundle.

That split explains a couple of things that confused me for an afternoon. The iOS Simulator can't run any of it, because MLX wants Metal and the Simulator hasn't got any, and Core ML's runtime throws a C++ exception there that Swift can't even catch. It also doesn't need the Neural Engine, which surprised me. I pinned Core ML to CPU and GPU only and it was no slower than letting it choose for itself. Pin it to the CPU alone and the time to the first word roughly doubles, so the GPU is the part you can't do without.

## I tested it on the wrong photos

My first proper test was a stock photograph of a pantry: about thirty labelled jars on a wooden shelf, with a bloke in a hoodie taking up half the frame. FastVLM gave me "various jars and containers, likely containing spices, grains, or other food items." When I pushed it to list what it could see, it wrote `jar, jar, jar, jar` until it ran out of tokens.

I wrote that up as a failure and moved on. Then I pointed the actual phone at the actual drawers in my kitchen, and it catalogued them.

The difference isn't subtle once you've seen it. Wide shots, with people and room context in them, get described and embellished. Close-ups where the thing fills the frame get catalogued. Going back to the test images with that in mind, a close-up of a drawer of jumbled cutlery came back as knives, spoons, forks, stainless steel, not arranged in any particular order. Three runs of an open sewing box gave me the same inventory each time, down to the orange-handled scissors.

So my test set was the problem, not the model. If you try this yourself: photograph things the way you'd actually use it, not the way a stock photographer would.

There are two failure modes that turn up whatever you point it at. It invents small background furniture, usually a wire fence that isn't in the picture. And it won't name the specific thing. A Brittany spaniel comes back as "a dog" every single time, even when I explicitly ask for the breed. Ask it "what breed is this?" on its own and it answers "a spaniel" instantly. It knows. It just won't volunteer it.

## The licence

I should have read this first.

The code is fine. Apple grants you use, modification and redistribution with no restriction on what you build. The weights are a separate document, the Apple Machine Learning Research Model License, and it rules out three things in one sentence:

> "Research Purposes" does not include any commercial exploitation, product development or use in any commercial product or service.

My apps are free and MIT, so I spent a happy minute assuming that let me off. It doesn't. "Product development" is sitting right there in the middle, and nothing qualifies it as commercial. Putting this in Rehang is product development whatever I charge, which is nothing. The licence is revocable too, and shipping the weights inside an app bundle hands them to people who aren't doing research and never agreed to anything.

Building the throwaway app is squarely inside the licence. That's what it's for. Shipping any of it isn't.

## The ones I can use

The good news is that the capability transfers even when the model doesn't, and that bit was easy. The MLX Swift examples package already ships eight vision models, several of them Apache 2.0, and they need no vendored code at all. SmolVLM2 at 500M parameters is 981 MB and slots straight in.

Check the licence per model rather than per family, by the way. Qwen3-VL 2B is Apache 2.0. Qwen2.5-VL 3B is under a Qwen *Research* licence, which is the same trap wearing a different hat.

On a drawer, SmolVLM2 holds up fine. On my octopus it didn't. Same photograph, both models, on the phone:

| Model | On disk | First word | All of it | What it said |
|---|---|---|---|---|
| FastVLM 0.5B | 1.7 GB | 1.03s | 2.03s | A plush toy of an orange octopus wearing a blue and black striped hat and scarf, holding a white ball, and has the word "INTUIT" on its tag. |
| SmolVLM2 500M | 981 MB | 3.45s | 4.20s | A plush toy with a blue and white striped hat and a blue and white striped scarf, holding a white ball in its hand, is sitting on a wooden table. |
| SmolVLM2 500M 8-bit | 597 MB | 3.54s | 4.04s | A plush toy with a blue and white striped hat and a blue and white striped scarf, holding a white ball in its hand, sits on a wooden table. |

FastVLM named the animal and read a word off a cloth tag. SmolVLM2 got the clothing right, missed the octopus entirely, missed the tag, and parked the toy on a wooden table it isn't sitting on. It was also three times slower to the first word, which is a wider gap on the phone than I'd measured on my Mac.

So the one I'm not allowed to use is the better one, and on a phone it isn't close. That's irritating, and it's the honest result.

## Smaller isn't faster

981 MB is a lot to stuff into an app, so I went looking for something smaller. This is where I learned the thing I actually want to tell you about.

I assumed a smaller model would be a quicker one. It isn't. SmolVLM2 at 256M ran at exactly the same speed as the 500M. Quantising the 500M down to 8-bit and then 4-bit made it a third of the size and didn't save me a millisecond.

The reason is one number I should have measured on day one: how many visual tokens the vision encoder hands over to the language model. FastVLM's encoder emits 256 of them, whatever you photograph. SmolVLM2 tiles the image and hands over somewhere between 900 and 1,200. Every token the model then generates has to attend across all of them, so that count sets the pace. Shrinking the language model, or squashing its weights, leaves the count completely untouched.

That's Apple's entire contribution in FastVLM, and it's why a model three times the size is three times faster. Fewer megabytes buys you disk. Only a different encoder buys you time.

Quantising still earned its keep, just not for speed. The 8-bit version is 384 MB smaller and said almost exactly the same thing in almost exactly the same time, which you can see in the table above. Push on to 4-bit and it falls over: it called a drawer of knives and forks "a scene of organized culinary delights."

## Two bugs that looked like success

Both of these cost me an hour, and neither one produced an error, so they're worth writing down.

The first: the image never reached the model at all. Apple's FastVLM processor takes a plain text prompt and inserts the image tokens itself. Every other model expects the prompt to arrive through the chat template, and that's what puts the image token in. Hand one of those a plain text prompt and your picture is silently dropped on the floor. The model then answers from the words alone, at length, with total confidence. Mine described the same black and white dog, twice, for two completely different photographs.

The second: MLX's GPU buffer cache. Apple's demo app sets it to 20 MB, which suits FastVLM fine because its vision half is Core ML and its working set is small. Give that same limit to a model whose vision tower is also MLX and it spends its life freeing and reallocating buffers. Raising it to 512 MB took one description from 104 seconds down to 38.

## Where it's going

I went through all twenty of my apps looking for the fit, and I got the answer backwards to start with.

What's Where? is the obvious one, and it's the one I'm leaving alone. It has a written rule that the app never looks at the photograph, because every item on a card has to trace back to words I actually said out loud. It's meant to be evidence. A model that puts a fence in a photo of a lawn on every run, and gives you a different answer to the same picture twice, is precisely what that rule is there to keep out.

Rehang is the fit. It already photographs each piece and already uses Vision to find the frame edges. It just calls them Piece 1 and Piece 2. Naming them off the photo lands on a promise the app already makes, which is that nothing needs typing, and if it gets one wrong I'm staring straight at the picture and can fix it with a tap.

That's the useful shape, I think. Not "where could I put a vision model", but "where is there already a photograph with a blank field next to it".

## The catch

Yes, it was worth doing, with a caveat I didn't expect to be writing.

A phone can describe what it sees, on device, in a few seconds, using a model you're allowed to ship. That's real, and it wasn't true a couple of years ago. But the best one I tested is the one I can't use, it's three times quicker than the one I can, and the finding that'll actually change what I build next is a fact about token counts rather than anything any of the models said.

There's a bigger catch coming, and it's a good one. iOS 27 puts image input into Apple's own Foundation Models framework, with OCR and barcode tools alongside it. No download, no licence to read, nothing in your bundle. When that lands, most of this post becomes history. Which fits the argument I started this series with: Apple keeps handing you things for free, and the job is working out what to build with them before everyone else does.

I'd still rather have found all this out now than build Rehang on an assumption.

---

Apple's [ml-fastvlm](https://github.com/apple/ml-fastvlm) is the original. The [MLX Swift examples](https://github.com/ml-explore/mlx-swift-examples) package is where the models I can ship came from.

*Co-authored by Claude. Claude built the throwaway app, ran the measurements, and helped write this post from the project's own notes. The arguments, the judgements and the mistakes are mine.*
