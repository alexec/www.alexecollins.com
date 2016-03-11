www.alexecollins.com
====================

	docker build -t site:1 .
	docker run -it -v $(pwd):/site -p 4567:4567 site:1
	open 192.168.99.100:4567

To upload:

	docker run -it -v $(pwd):/site -p 4567:4567 site:1 bash
	cd site
	middleman build
	quit

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
