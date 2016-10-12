#! /bin/sh
set -eu

bundle exec middleman build --parallel $*
