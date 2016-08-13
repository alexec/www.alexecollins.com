#! /bin/sh
set -eu

docker run --rm -it -v $(pwd):/site -p 4567:4567 site:1 sh -c 'bundle install && middleman serve'
