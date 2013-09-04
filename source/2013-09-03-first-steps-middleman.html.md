---
title: First Steps with Middleman
---

Middleman is a simple static site generator in Ruby. You create your site in markdown, run the builder and deploy, like you might an application. As a developer, this suites me, and after watching a friends successful transition to it, I thought I'd give it a go.

I ended up doing the following steps:

* Exporting the pages from Drupal as a CSV file, using ™ and € as delimiters :)
* Writing [a script](https://github.com/alexec/www.alexecollins.com/blob/master/convert.rb) that parsed the CSV file, extracting the date, title and content and creating a blog post for each page.
* Tweaking the output several times to fix problems, e.g. un-closed tags, stop-words in page title.
* As it doesn't support /?=... style URLs, I created [a 404 page](/404) with a list of the most popular posts.
* Running [my link checker](/content/web-site-link-checker) to check I'd not broken too many links.
* Updating the template to have Google Analytics tracking, and Disqus comments.
* Manually inspecting the most popular pages for errors.
* Checking on modile.
* Enabling a Rakefile to publish it to Github Pages for preview.

I'd already trimmed my site down when I moved it to EC2. This time I lost the recent post, recent comments and tags. I may try to reinste the tags.
