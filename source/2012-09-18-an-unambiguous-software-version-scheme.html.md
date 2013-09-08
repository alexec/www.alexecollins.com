---
title: "An unambiguous software version scheme"
tags: oped
---
When people talk about software versioning schemes they often refer to the commonly used  X.Y.Z numerical scheme for versioning. This is often referred to major.minor.build, but these abstract terms are not useful as they don't explicitly impart any meaning to each numerical component. This can lead to the simplest usage, we just increment the last number for each release, so I've seen versions such as 1.0.35. Alternatively, versions become a time consuming point of debate. This is a shame as we could impart some clear and useful information with versions.

I'm going  to suggest that rather than thinking "X.Y.Z" we think "api.feature.bug". What do I mean by this? You increment the appropriate number for what your release contains. For example, if you have only fixed bugs, you increment the last number. If you introduce even one new feature, then you increment the middle number. If you change a published or documented API, be that the interface of a package, a SOAP or other XML API, or possibly the user interface (in a loose sense of the term "API") then the first number. 

This system is unambiguous, no need for discussions about the numbering.

You zero digits to the right of any you increment, so if you fix a bug and introduce a new feature after version 5.3.6 then the new version is 5.4.0. Unstated digits are assumed to be zero, so 5.4.0 is the same as 5.4.0.0 and 5.4.0.0.0.0.0.0.0...

The version is not a number, and it does not have digits. The version 5.261.67 is pretty unusual, but not invalid. Don't let it put you off.

You might need to change an API due to bug fix, but you'll need to be diligent, and cold to any politicking by increasing the API digit. Otherwise the scheme looses value and you might as well just use a single number for versioning.

What if you're on version 5 of the product and the product lead has told everyone version 6 will be something special, but you need to fix a bug that means an API change? You need a hybrid version system, which consists of the external "product version" and the internal "software version". 

What about branching for production support? Technically no features, but quite possibly one branch per customer. CVS has a suitable system, take the version of the release, append two digits, the first to indicate the branch, the second for the fix number. For example, if you branch from 5.4.0 then the first release will be 5.4.1.0, the next branch's second release would be 5.4.2.1.
