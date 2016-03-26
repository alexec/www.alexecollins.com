#! /bin/sh
set -eu

docker run --rm -it -v $(pwd):/site site:1 middleman build
