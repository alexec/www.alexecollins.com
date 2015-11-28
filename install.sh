#! /bin/sh
set -eux

gem install 'therubyracer'
gem install "middleman"
gem install "middleman-blog"
#gem "middleman-gh-pages"
gem install "middleman-syntax"

# For feed.xml.builder
gem install "builder"

#gem 'rack-rewrite'
#gem 'middleman-livereload'
gem install 'nokogiri'
gem install 'middleman-minify-html'
#gem install 'middleman-deploy'
