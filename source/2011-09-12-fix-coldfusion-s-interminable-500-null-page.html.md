---
title: "Fix ColdFusion's Interminable 500 null Page"
---
When ColdFusion fails in certain fashions, e.g. syntactically incorrect cfscript, it doesn't always provide any reporting. It takes a bit of rooting around to find out that the /500.html page is shown to the user when this happens. However, if the onError function is missing (if you're using Application.cfc) or there is no cferror tag (in the case of Application.cfm), nothing is reported.

Solution: Create the appropriate function. 

This page should also log the attributes of cfcatch too. A good example comes with CF: /usr/local/coldfusion/wwwroot/WEB-INF/exception/detail.cfm

See: 
http://www.coldfusionjedi.com/index.cfm/2007/12/5/The-Complete-Guide-to-Adding-Error-Handling-to-Your-ColdFusion-Application
