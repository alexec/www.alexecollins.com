---
title: "Testing - Pt 3 - Writing Tests"
tags: testing,oped
---
<p class="c3"><span>Tests should be fast to run and fast to write:</span></p>
<p class="c2"><span></span></p>
<ol class="c0" start="1">
	<li class="c1"><span>Writing tests should not require time-consuming set-up of databases, DLLs or environments, automate anything of this nature.</span></li>
	<li class="c1"><span>You should not require tacit knowledge of customised systems, no ones want to indulge in tedious manual set up. It&#39;s just cost.</span></li>
	<li class="c1"><span>Ask yourself - is running someone else&#39;s tests should be possible with a single button?</span></li>
	<li class="c1"><span>The tests themselves should not take long to write.</span></li>
</ol>
<p class="c2"><span></span></p>
<p class="c3"><span>Don&#39;t confuse tests for production code:</span></p>
<p class="c2"><span></span></p>
<ol class="c0" start="1">
	<li class="c1"><span>Don&#39;t worry too much about writing the most &quot;effective Java&quot; test code, or reuse. Fields don&#39;t need to be &quot;private final&quot;.</span></li>
	<li class="c1">You don't need to enforce you coding standards on tests.</li>
</ol>

<p>Test the behaviour, not the method (@Test void testMethodX anyone?):</p>

<ol>
	<li class="c1"><span>Consider a BDD based system.</span></li>
</ol>
<p class="c2"><span></span></p>
<p class="c3"><span>Consider writing test for interfaces, and then using a</span><span><a class="c5" href="https://blogs.oracle.com/jacobc/entry/parameterized_unit_tests_with_junit">&nbsp;</a></span><span class="c4"><a class="c5" href="https://blogs.oracle.com/jacobc/entry/parameterized_unit_tests_with_junit">parameterized</a></span><span>&nbsp;runner that will run the same set of tests for each implementation.</span></p>
<p class="c2"><span></span></p>
<p class="c3"><span>Test failure should clearly feedback into fixes:</span></p>
<p class="c2"><span></span></p>
<ol class="c0" start="1">
	<li class="c1"><span>Capture output from tests so failure can be diagnosed.</span></li>
	<li class="c1"><span>Make sure failed tests can be run in isolation from their suite, so you can focus on fixing failing tests.</span></li>
	<li class="c1"><span>How long is the mean time between test failure, fixing the faulty code and rerun of the test?</span></li>
</ol>
<p class="c2"><span></span></p>
<p><a href="/content/testing-pt-2-choosing-your-system">&larr; Back to part 2</a> ~ <a href="/content/testing-pt-4-test-support-and-test-doubles">On to part 4 &rarr;</a></p>
