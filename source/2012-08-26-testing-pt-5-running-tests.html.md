---
title: "Testing - Pt 5 - Running Tests"
tags: testing,oped
---
<p class="c4"><span>Be &quot;realistic&quot;:</span></p>
<p class="c2"><span></span></p>
<ol class="c3" start="1">
	<li class="c1"><span>Prefer running tests on a representative set-up using real code rather than using fakes.</span></li>
	<li class="c1"><span>Try and run your tests out of container, so the software is run in as close to production set-up as possible.</span></li>
	<li class="c1"><span>If software runs on specific environment, run the tests there too, i.e. integration tests are preceded by a deployment (and implicit test thereof), this in turn implies that deployment should be a button press.</span></li>
</ol>
<p class="c2"><span></span></p>
<p class="c4"><span>Make then repeatable:</span></p>
<p class="c2"><span></span></p>
<ol class="c3" start="1">
	<li class="c1"><span>Tests written by one person can easily be accessed by another, i.e. version controlled.</span></li>
	<li class="c1"><span>No tedious, error prone work getting tests into version control, single button commit.</span></li>
	<li class="c1"><span>Can they run on computers other than your dev machine?</span></li>
	<li class="c1"><span>If it&#39;s not automated, it&#39;s not repeatable.</span></li>
</ol>
<p class="c2"><span></span></p>
<p class="c4"><span>Integrate with the build system:</span></p>
<p class="c2"><span></span></p>
<ol class="c3" start="1">
	<li class="c1"><span>You tests should run on your dev machine, and the CI server and in QA, each run will give you more confidence in the finished product.</span></li>
	<li class="c1"><span>They should run in CI, probably headless, alongside concurrent executions of the same tests. Do they use the same hardcoded directories; are they listening on the same ports?</span></li>
</ol>
<p class="c2"><span></span></p>
<p><a href="/content/testing-pt-4-test-support-and-test-doubles">&larr; Back to part 4</a></p>
