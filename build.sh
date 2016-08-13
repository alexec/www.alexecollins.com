#! /bin/sh
set -eu

docker run --rm -it -v $(pwd):/site site:1 sh -c 'bundle install && bundle exec middleman build'
