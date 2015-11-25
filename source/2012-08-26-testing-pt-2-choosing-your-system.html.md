---
title: "Testing - Pt 2- Choosing Your System"
tags: testing,oped
---
<p class="c0"><span>Chose a system that has a low barrier to entry, something people are keen to learn, or will already know:</span></p>
<p class="c1 c0"><span></span></p>
<ol class="c4" start="1">
	<li class="c2 c0"><span>One where there&#39;s value in learning, such as a popular industry standard, and those systems will be better documented, better understood, more reliable, and your colleagues will be easier to get on board.</span></li>
	<li class="c2 c0"><span>Use the system &quot;in-paradigm&quot;, by which I mean, use it as was meant to be used, not in an unusual &quot;out-of-paradigm&quot; way, this will make your colleagues life difficult, and prevent adoption.</span></li>
</ol>
<p class="c1 c0"><span></span></p>
<p class="c0"><span>Can you can test multiple configurations, where some tests are only applicable to some modules and configurations?</span></p>
<p class="c0 c1"><span></span></p>
<p class="c0"><span>Is it robust?</span></p>
<p class="c1 c0"><span></span></p>
<ol class="c4" start="1">
	<li class="c0 c2"><span>Will changes to test subjects lead easily to identifying the tests that need changing? A change to your underlying implementation shouldn&#39;t silently break the tests.</span></li>
	<li class="c2 c0"><span>Avoid completely dynamic languages, compile time checking prevents typographical errors and identifies tests that might need changing if the test subject changes.</span></li>
</ol>
<p class="c1 c0"><span></span></p>
<p class="c0"><span>Consider if the system is usable by both developers, and to less technical people - will you want testers or QA to be able to write tests?</span></p>
<p class="c1 c0"><span></span></p>
<p class="c0"><span>Once upon a time I thought this was a no brainer: is the test system fully automated? Or, is it going to cost your company money each time you run them?</span></p>
<p><a href="/testing-pt-1">&larr; Back to part 1</a> ~ <a href="/testing-pt-3-writing-tests">On to part 3 &rarr;</a></p>
