www.alexecollins.com
====================

	docker build -t site:1 .
	docker run --rm -it -v $(pwd):/site -p 4567:4567 site:1 middleman serve
	open 192.168.99.100:4567

To upload:

	docker run --rm -it -v $(pwd):/site -p 4567:4567 site:1 middleman build
	./upload.sh

Promote to:

	https://dzone.com/links
	https://plus.google.com
	https://www.linkedin.com/
	https://news.ycombinator.com/submit
	https://twitter.com/

Reference:

* http://ironsummitmedia.github.io/startbootstrap-agency/

Testing

* Home
* Sitemap
* RSS
* Blog Home
* Blog Post
* linkedin
* twitter
* Contact
* On iPad
* On iPhone
* Analytics
