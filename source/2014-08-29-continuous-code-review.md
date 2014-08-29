---
title: Continuous Code Review
date: 2014-08-29 20:06 UTC
tags: code review
---
**10 Dos and Don'ts**

1. Do have people experienced with the code reviewing the code of those less familiar. Effectiveness largely depends on experience and familiarity. 
2. Don't review code if you're unfamiliar with it, unless you really want to report of formatting errors.
3. Do allow people to review code on their own in quiet.
4. Don't review code in a meeting, it's ineffective and a time waster.
5. Do a two pass review, one to clean-up, a second for correctness.
6. Do review your own code, they'll find half the defects on your own.
7. Do have two reviewers, it's the most effective number. 
8. Focus on correctness and maintainability, not formatting.
9. Do have a check list of things to check.
10. Don't forget to challenge assumptions that the developer made. Go to the source of the requirements.

How do I like to review? All work is done on branch, as soon as a developer creates a pull request, I ask them to book me in their calendar later that day. I go over to their desk and sit with them discussing the requirements.  We then go over the code together and I ask them questions about it. We add TODOs into the code where things need to be considered. I always look at test quality and coverage, and I always compare static data with the source. This is know, colloquially as an "over the shoulder".

I don't do solo code reviews. I'm not good at them, but I know who on my team is and I ask them to do them.

Pull requests are public, so anyone can look at the code.

| No Review | Code isn't reviewed |
| Pre-Merge/Pull Request | Code is review before merge to master |
| Pre-Push | Code is review before being pushed to a remote branch. |  
| Pre-commit Review | Code is reviewed before it committing, the aim being that every commit is good. |
 Pair Programming | Every line of code is reviewed as it's written and even committed straight to master. |