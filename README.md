www.alexecollins.com
====================

To publish, push to `master`. GitHub Actions (`.github/workflows/pages.yml`) builds the site
and deploys it to GitHub Pages at https://www.alexecollins.com.

To build locally (needs Ruby 3.3, see `Gemfile.lock`):

	./install.sh
	./build.sh

Drafts: add `published: false` to an article's front matter and it is skipped by the build.

Promote to:

	https://dzone.com/links
	https://plus.google.com
	https://www.linkedin.com/
	https://news.ycombinator.com/submit
	https://twitter.com/

Testing

* Home
* Blog Home
* Blog Post
* On iPad
* On iPhone
* Analytics
