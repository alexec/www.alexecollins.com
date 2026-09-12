---
title: The vision model I can't ship
date: 2026-09-11 12:00 UTC
tags: ios, claude-code, ai
published: true
---
Point my phone at something, press the shutter, and it tells me what it is. Here it is on a plush octopus in a bobble hat that sits on my desk.

[![Three vision models describing the same photograph of a plush octopus toy](/images/the-vision-model-i-cant-ship/three-models.jpg)](/images/the-vision-model-i-cant-ship/three-models-full.jpg)

*Three models, one photograph, on an iPhone 15 Pro Max in aeroplane mode. Click for the full-size version.*

The one at the top got the animal and read the word off the tag. The two underneath got the hat and the scarf and missed both.

No network. The models are in the app bundle, the phone does the work, and the picture never leaves it.

That is the good news. The rest of this post is what I got wrong on the way there, which turned out to be more useful than the thing working.

## What FastVLM actually is

Apple published FastVLM last year and the code is on GitHub. It gets described as a Core ML model. That is half true, and the half matters.

FastVLM is two models in one folder. The eye is FastViTHD, a vision encoder that ships as a Core ML package, 482 MB. The mouth is a Qwen2 0.5B language model that runs on MLX, on the GPU, 1.2 GB. Apple ships both halves in one zip and the app carries the lot, which is 1.7 GB on disk.

The split explains a few things that confused me for an afternoon. The iOS Simulator cannot run any of it, because MLX needs Metal and the Simulator has none, and Core ML's runtime throws a C++ exception there that Swift cannot catch. It does not need the Neural Engine either. I pinned Core ML to CPU and GPU only and it was no slower than letting it choose, so on my Mac the ANE is not buying anything. Pin it to CPU alone and the time to first word roughly doubles, so the GPU is the part that is not optional.

## It works, and the envelope is sharper than I expected

My first test was a stock photograph of a pantry: thirty labelled jars on a shelf, with a man in half the frame. The model gave me "various jars and containers, likely containing spices, grains, or other food items". When I pushed it to list the contents it wrote `jar, jar, jar, jar` until it hit the token limit.

I wrote that up as a failure. Then I pointed it at a drawer in my own house and it catalogued the drawer.

The difference is not subtle once you see it. Wide scene photographs, with people and room context in them, get described and embellished. Close-up shots where the thing fills the frame get catalogued. A kitchen drawer of jumbled cutlery came back as knives, spoons, forks, stainless steel, not arranged in any order. Three consecutive runs of the sewing box gave the same core inventory each time.

So the test set was the problem, not the model. Worth remembering if you try this: photograph it the way you would actually use it.

There are two failures that show up whatever you photograph. It invents small background furniture, most often a fence that is not in the picture, and it never names the specific thing. A Brittany spaniel comes back as "a dog" at every length I asked for, even when the prompt asks for the breed by name. Ask it "what breed is this?" outright and it answers "a spaniel" immediately. It knows and it will not volunteer it.

## The licence

Then I read the licence, which I should have done first.

The code is fine. Apple grants use, modification and redistribution with no restriction on what you build. The weights are a different document, the Apple Machine Learning Research Model License, and it rules out three things separately:

> "Research Purposes" does not include any commercial exploitation, product development or use in any commercial product or service.

My apps are free and MIT, so I spent a minute hoping that helped. It does not. "Product development" sits there on its own, unqualified by commercial. Putting this in an app is product development whatever I charge for it. The licence is revocable too, and shipping weights inside an app bundle hands them to people who are not doing research and have not agreed to anything.

Building the proof of concept is squarely inside the licence. That is what it is for. Shipping any of it is not.

## Finding one I can ship

The capability transfers even though the model does not, and that turned out to be the easy part. The MLX Swift examples package already carries eight vision models, and several are Apache 2.0. SmolVLM2 at 500M parameters is 981 MB and needs no vendored code at all.

On a drawer it holds up. A sewing box came back as "an open wooden sewing box filled with various spools of thread, including blue, red, and green, and a pair of orange scissors", which is true down to the orange handles, and it read the camera's date stamp off the corner of the photo as well.

On the octopus it did not. Both models saw the same picture. Here is what each said, and what it cost on the phone:

| Model | On disk | First word | All of it | What it said |
|---|---|---|---|---|
| FastVLM 0.5B | 1.7 GB | 1.03s | 2.03s | A plush toy of an orange octopus wearing a blue and black striped hat and scarf, holding a white ball, and has the word "INTUIT" on its tag. |
| SmolVLM2 500M | 981 MB | 3.45s | 4.20s | A plush toy with a blue and white striped hat and a blue and white striped scarf, holding a white ball in its hand, is sitting on a wooden table. |
| SmolVLM2 500M 8-bit | 597 MB | 3.54s | 4.04s | A plush toy with a blue and white striped hat and a blue and white striped scarf, holding a white ball in its hand, sits on a wooden table. |

FastVLM named the animal and read "INTUIT" off a small cloth tag. SmolVLM2 got the clothes right, missed the octopus, missed the tag, and put the toy on a wooden table it is not sitting on. It was also three times slower to the first word, which is a wider gap on the phone than I measured on my Mac.

So the model I am not allowed to use is the better one, and on a phone it is not close. That is annoying and it is the honest result.

The two precisions of SmolVLM2 said almost the same thing in almost the same time, which settles something I had been going back and forth on. The 8-bit version is 384 MB smaller for no loss I can see, so the full-precision one has no reason to exist.

Check the licence per model rather than per family, by the way. Qwen3-VL 2B is Apache 2.0. Qwen2.5-VL 3B is under a Qwen *Research* licence, which is the same trap in a different font.

981 MB is still a lot to put in an app, so I went looking for something smaller, and this is where I learned the thing I actually want to tell you.

## Megabytes buy disk, not time

My assumption was that a smaller model would be a faster one. It is not, and quantising does not help either.

SmolVLM2 at 256M ran at the same speed as the one at 500M. Quantising the 500M to 8-bit and then 4-bit made it a third of the size and no quicker at all. The reason is in one number that took me embarrassingly long to measure: how many visual tokens the vision encoder hands the language model.

FastVLM's encoder emits exactly 256 tokens, whatever the picture. SmolVLM2 tiles the image and hands over between 900 and 1,200. Every token the model then generates has to attend over all of them, so that count sets the pace. Shrinking the language model or squashing its weights leaves the count untouched.

That is Apple's whole contribution in FastVLM, and it is why a model three times bigger is three times faster. Fewer megabytes buys you disk. Only a different vision encoder buys you time.

Quantising still earned its place, just not for speed. 8-bit is 384 MB smaller than the full-precision version and gives me exactly the same short answer, word for word, on every picture I tried. It pays for it in the longer descriptions, where the detail thins out. "Blue, red, and green, and a pair of orange scissors" becomes "various sewing supplies, including spools of thread, scissors, and a pair of scissors". 4-bit is a step too far. It called a drawer of knives and forks "a scene of organized culinary delights".

## Two bugs that pretended to work

Both of these cost me an hour and neither produced an error, so they are worth writing down.

The first is that the image never reached the model. Apple's FastVLM processor takes a plain text prompt and inserts the image tokens itself. Every other model expects the prompt to arrive through the chat template, which is what puts the image token in. Hand one of those a plain text prompt and the picture is silently dropped. The model then answers from the words alone, at length and with total confidence. Mine described the same black and white dog, twice, for two completely different photographs.

The second is MLX's GPU buffer cache. Apple's demo app sets it to 20 MB, which suits FastVLM because its vision half is Core ML and its working set is small. Give that limit to a model whose vision tower is also MLX and it spends its time freeing and reallocating buffers. Raising it to 512 MB took one description from 104 seconds to 38.

## What I'm going to use it for

I audited my twenty apps for where this fits, expecting the answer to be the obvious one. It wasn't.

What's Where? is my house inventory app. You photograph a cupboard and say what is in it, and the app never looks at the photograph. That is a written rule, and the reason is that every listed item has to trace back to words I actually said. It is meant to be evidence. A model that puts a fence in a photograph of a lawn on every single run, and gives a different answer to the same picture twice, is exactly what that rule keeps out.

The fit is Rehang, which lets me arrange pictures on a wall in AR before drilling any holes. It already photographs each piece and uses Vision to find the frame edges. It just calls them Piece 1 and Piece 2 unless I name them myself. Naming them from the photo lands on a promise the app already makes, which is that nothing needs typing, and if it gets one wrong I am looking straight at the picture and can fix it in a tap.

That is the useful shape, I think. Not "where can I put a vision model", but "where is there already a photograph and a blank field next to it".

## Worth doing?

Yes, with a caveat I did not expect to be writing.

A phone can describe what it sees, on device, in a few seconds, from a model you are allowed to ship. That is real and it was not true a couple of years ago. But the best one I tested is the one I am not allowed to use, it is three times quicker than the one I can, and the thing I learned that will change what I build next is a fact about token counts rather than anything the models said.

iOS 27 puts image input into Apple's own Foundation Models framework, with OCR and barcode tools alongside it. No download, no licence to read, nothing in the bundle. When that lands, most of this post becomes history. I would still rather have found all this out now than build on an assumption.

---

The proof of concept is called FastVLM, which is lazy naming, and it is a camera, a shutter and three models arguing about the same photograph. Apple's [ml-fastvlm](https://github.com/apple/ml-fastvlm) is the original, and the [MLX Swift examples](https://github.com/ml-explore/mlx-swift-examples) package is where the models I can ship come from.

*Co-authored by Claude. Claude built the proof of concept, ran the measurements, and helped write this post from the project's own notes. The arguments, the judgements and the mistakes are mine.*
