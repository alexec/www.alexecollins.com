#! /bin/sh
set -eu

cd $(dirname $0)

bundle exec middleman build --parallel $*
