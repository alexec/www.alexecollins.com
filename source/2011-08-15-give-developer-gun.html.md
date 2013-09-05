---
title: "Give the Developer a Gun"
---
I believe that if you're given a set of tools to do a job, you'll often try them all before using the correct one for the job. There's not such thing as a good developer, just one that does what they're asked to do and ones that don't, So, if there's no feedback between the way that they do their job (promotion and renumeration) and the type of job you want them to do (presumably few bugs and cheap to maintain), then you can't expect them to do the job you want them to do.

If you allow someone to commit code to your SCM that doesn't need to be statically checked, that does not have to have automated tests written for it, isn't expected to write code/commit comments, that isn't peer reviewed and where that review process feeds back then you should assume that you're going the get.

<ol>
<li>Code that doesn't compile and as a direct result will be prone to bugs.</li>
<li>Code that's not been tested well, and - because code that is not designed for testing is not easy to test - will be expensive to maintain.</li>
</ol>

If people are rewarded for doing the job quickly, not well, then you'll be looking a mess that is expensive to maintain.

One mans "work around" is another's "hack" and someone else's "attack".

If you give the developer a gun, he won't shot himself or you. He'll make a mess of your code.
