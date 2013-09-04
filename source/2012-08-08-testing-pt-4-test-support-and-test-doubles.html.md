---
title: "Testing - Pt 4 - Test Support and Test Doubles"
---
<p class="c1"><span>Document supporting code:</span></p>
<p class="c1 c4"><span></span></p>
<ol class="c3" start="1">
	<li class="c0"><span>Test doubles or fixtures won&#39;t be reused if people don&#39;t know about them or how.</span></li>
</ol>
<p class="c1 c4"><span></span></p>
<p class="c1"><span>With JUnit, consider using </span><span class="c5"><a class="c2" href="/content/tutorial-junit-rule">@Rules</a></span> to provide mixin-esq components for tests.</span></p>
<p class="c1 c4"><span></span></p>
<p class="c1"><span>Prefer fakes:</span></p>
<p class="c1 c4"><span></span></p>
<ol class="c3" start="1">
	<li class="c0"><span>They&#39;re generally more versatile and reusable than stubs, dummies or mocks.</span></li>
	<li class="c0"><span>They&#39;ll give you a better understanding of the subject than other types of doubles.</span></li>
	<li class="c0"><span>They can often share a code with the implementation, and thereby test that as well.</span></li>
	<li class="c0"><span>Have the ability to directly control fakes by an interface, e.g. to put components into error mode that cannot be stimulated by normal APIs, e.g. network issues or hardware failures.</span></li>
</ol>
<p>Fake the third-party:</p>
<ol>
	<li class="c0">In my job there&#39;s a fair amount of JNI/JNA code that talks to hardware. By faking just the JNI methods, we can simulate various things including timeouts of failures. I&#39;ve done similar things with faking serial devices, faking javax.comm.SerialPort and pre-loading it with fake data that simulates failures or other errors.</li>
	<li>This will work equally as well with RESTful APIs and the like.</li>
</ol>
<p class="c1 c4"><span></span></p>
<p><a href="/content/testing-pt-3-writing-tests">&larr; Back to part 3</a> ~ <a href="/content/testing-pt-5-running-tests">On to part 5 &rarr;</a></p>
