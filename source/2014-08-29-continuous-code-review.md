---
title: Continuous Code Review
date: 2014-08-29 20:06 UTC
tags: code review
---
**10 Dos and Don'ts**

1. Do have people experienced with the code reviewing the code of those less familiar. Effectiveness largely depends on experience and familiarity. 
2. Do allow people to review code on their own in quiet.
3. Don't review code in a meeting, it's ineffective and a time waster.
4. Do a two pass review, one to clean-up, a second for correctness.
5. Do review your own code, they'll find half the defects on your own.
6. Do have two reviewers, it's the most effective number. 
7. Do focus on correctness and maintainability, not on formatting and style.
8. Do have a check list of things to check.
9. Don't forget to challenge assumptions that the developer made. 
10. Don't forget the code reviews are a learning opportunity.

How do I like to review? All work is done on branch, as soon as a developer creates a pull request, I ask them to book me in their calendar later that day. I go over to their desk and sit with them discussing the requirements.  We then go over the code together and I ask them questions about it. We add TODOs into the code where things need to be considered. I always look at test quality and coverage, and I always compare static data with the source. This is know, colloquially as an "over the shoulder".

I don't do solo code reviews. I'm not good at them, but I know who on my team is and I ask them.

Here's you reviewing options, from the longest feedback cycle time, to the fastest.

| No Review | Code isn't reviewed |
| Pre-Merge/Pull Request | Code is review before merge to master |
| Pre-Push | Code is review before being pushed to a remote branch. |  
| Pre-commit Review | Code is reviewed before it committing, the aim being that every commit is good. |
 Pair Programming | Every line of code is reviewed as it's written and even committed straight to master. |