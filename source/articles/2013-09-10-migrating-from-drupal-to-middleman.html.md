---
title: Migrating from Drupal to Middleman
date: 2013-09-10 07:15 UTC
tags: middleman,drupal,ruby
---
Some further thoughts on migrating from Drupal to Middleman.

Some tasks have turned out to be especially time-consuming. Specifically, I've actually spent a lot of time tidying up content to correct small mistakes. Migrating the web site means that you end up reviewing the pages, and this (for me at least) means you find yourself wanting to polish them.

I failed to put a plan in place. This is because the migration started out as an experiment, but I wished I'd planned where to deploy it first. Setting up Apache on my EC2 intsance was a bit of a fiddle. I've yet to use it as an excuse to install Nginx.

You need more tooling, as you cannot just edit in the browser, you need to install all the tools for development: Git, RVM (as you need Ruby 1.9.3 and OS-X comes with 1.8.7) and all the Ruby Gems you need. I'm yet to find a reasonable Markdown editor, though the only barrier to this is time. This means I edit everything in a mixture of vi and TextEdit.

I spent a lot of time getting Disqus to migrate the comments to new URLs. This works now, but was fustrating.

I had to do more coding that I expected, e.g. creating my own tag cloud, [404](/404) page and [sitemap](/sitemap).

Setting up [Middleman Syntax](https://github.com/middleman/middleman-syntax) was a pleasure and I love it's styling. [Middleman Github Pages](https://github.com/neo/middleman-gh-pages) seems like a nice idea, but to make sure the 404 page worked, I couldn't use relative assets. There's probably work-around if you're deseparte for free hosting.


Further Reading
---
* [Building static web sites with Middleman](http://12devs.co.uk/articles/204/)
* [CMSs are dead, long live CMSs](http://www.darrenmothersele.com/blog/2013/08/02/cms-is-dead-long-live-cms/)
* [Hacking up sits with Middleman](http://darrenknewton.com/2012/09/16/hacking-up-sites-with-middleman/)
