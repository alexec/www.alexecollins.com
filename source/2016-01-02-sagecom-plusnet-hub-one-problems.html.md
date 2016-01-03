---
title: Sagecom Plusnet One Hub Problems
date: 2015-01-02 01:00 UTC
---
I upgaded to Plusnet super-fast fibre broadband recently, and have had some teething issues with it. Since I could not find anyone who had the same problems on Google, I'm going to take this opportunity to share the resolutions.

Problem 1: The BT engineer who came to install the router did not know you need to type your password into it to get it to work. 

Problem 2: My 2007 MacBook would not connect. This is solved by disabling IPv6 in the network settings. Interestingly, it worked fine when booting into Ubuntu, so maybe this is on OS-X issue rather than a MacBook hardware issue.

Problem 3: The speed would often be very slow, and my XBox 360 would not connect complaining that there were "two networks with the same name". The router has two different networks, 2.4Ghz and 5GHz, but they have the same name. This confused the XBox. The solution -- login to the router (the IP is 192.168.1.254, the password is on the back of the router) and rename one of the networks to something else (e.g. whatever name it had, and then append "2.4 GHz" to it). You can then choose the precise network you want -- choose the 5 GHz if you can as it is faster and more reliable, but use the 2.4 if that one does not work).
