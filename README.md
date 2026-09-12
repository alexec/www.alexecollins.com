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

App privacy and support pages
-----------------------------

Every app of mine keeps its privacy policy and its support page here, not in its own
repository, because the app repositories are going private and an App Store record has to
point at something the public can read. The App Store Connect record for each app points at
these two URLs.

### The URL shape

	https://www.alexecollins.com/<app-name>/privacy.html
	https://www.alexecollins.com/<app-name>/support.html

Three decisions are baked into that, and the fourteen apps after Hard Stop inherit all three.

**The app's name, not the folder's.** Several checkouts are named after something the app is
no longer called: Pictured lives in `Rehang`, Out of Mind in `Braindump`, Hold Still in
`Daily`, Walkist in `Unsocial`. The name on the App Store is the one still true in a year, so
that is the one in the URL. Slug it by lowercasing, dropping apostrophes, turning every other
run of non-letters into a single hyphen, and trimming the ends:

| App | Slug |
|---|---|
| Hard Stop | `hard-stop` |
| What's Where? | `whats-where` |
| Fed the Dog | `fed-the-dog` |
| Call Your Mom | `call-your-mom` |

The apostrophe is deleted rather than hyphenated, so it is `whats-where` and not
`what-s-where`. The question mark is dropped the same way.

**A literal `.html`, not a directory index.** The rest of the site uses `directory_indexes`,
so `/about-me/` is a folder with an `index.html` in it. These pages opt out, through two globs
in `config.rb`:

	page "/*/privacy.html", directory_index: false
	page "/*/support.html", directory_index: false

A store record's URL is close to permanent once the app is approved, and a real file at a real
path keeps working on any static host, with no dependence on how a server handles a trailing
slash. The globs mean adding an app needs no change to `config.rb` at all.

**`www`, not the bare domain.** `alexecollins.com/...` works, but it answers 301 and sends you
to `www`. Write the `www` form into App Store Connect so Apple follows no redirect.

### The page template

Two files per app, both Markdown with front matter. The layout prints the `title` as the `h1`,
so the body starts at the date and never repeats the heading.

	source/<app-name>/privacy.html.md
	source/<app-name>/support.html.md

	---
	title: <App Name> Privacy Policy
	---

	_Last updated: <D Month YYYY>_

	...

Take the text from the app repository's `PRIVACY.md` and `SUPPORT.md` and change three things.

1. **Drop every GitHub link.** The repository is private by the end of the task, so an "open an
   issue" line is a dead end for anyone who reads it, and a support page that needs a GitHub
   account is not a support page. Both files in the app repositories point at issues today.
   Replace them with `alex@alexecollins.com`, which is already public as the author address on
   sixteen repositories, so publishing it gives nothing away.
2. **Cross-link the pair.** The privacy page ends by pointing at the support page and the
   support page ends by pointing at the privacy page, both as absolute site paths.
3. **Bump the date** to the day you publish, because the contact route changed.

Check the text for anything that should not be public under my name before it goes up: another
person's name, an email address that is not mine, a device id. The PII audit found all three
across these repositories.

### Publishing

Push to `master`. GitHub Actions builds and deploys, and the pages are live a minute or so
later. `upload-to-gcloud.sh` is left over from when the site sat in a Google Cloud Storage
bucket and does not publish anything now: the domain has been on GitHub Pages since before
this was written, and `gsutil` is not installed on the Mac. Do not run it.

Then check both URLs actually answer 200 from outside before writing either into App Store
Connect. A privacy URL that 404s is a 5.1.1 rejection.

	curl -sS -o /dev/null -w '%{http_code}\n' https://www.alexecollins.com/hard-stop/privacy.html

The URL of every app that has been done is in `~/Tracking/APP-URLS.md`.
