---
title: "Beyond JUnit"
---
JUnit is the defacto Java unit testing framework, but there's a couple of new (and not so new) frameworks out there for web development that might be of interest. Questions you might want to ask yourself prior to adoption:

<ul>
<li>Are they fast and easy to develop and therefore low cost?
<li>Are they fast to run and therefore encourage adoption?
<li>Do they require maintenance and therefore engender on going cost?
<li>Can I execute them in my nightly build?
<li>Do they ultimately allow you to write more bug free code, faster?
</ul>

<h2>Mockito</h2>

This is a mocking framework that makes it straight forward and fast to create mock backed tests. This reduces the cost of setting up databases and avoids writing your own. It seems the API isn't as stable as it might be, but it has a terse and intuitive syntax.

http://mockito.org/

<h2>SureAssert</h2>

SureAssert has an annotation based mechanism for writing tests. This makes it easy to write the tests, and an Eclipse plug-in means that your incremental builds are incrementally tested.

http://www.sureassert.com/

<h2>JS Test Driver</h2>
Similar to Selenium below, this allows you the create test cases for JavaScript using a JUnit style syntax. The main caveat is that you need to factor your tests suitably for testing, and most JavaScript I've seen is not like that.

http://code.google.com/p/js-test-driver/

<h2>Selenium</h2>

Selenium is a top-down browsers plug in and framework that allows you to record a set of macro-like actions within a browser along with a set of assertions on those actions. E.g.

<ol>
<li>Open page X.
<li>Click button Y.
<li>Expect text Z.
</ol>

It's nice because the tests are focussed on important scenarios (checking that pages really open and transactions actually occur), and can be exported as JUnit tests that can run as part of the nightly build. However. it's brittle and because it depends on the app running, slow.

http://seleniumhq.org/
