#! /bin/sh
set -eu

cd $(dirname $0)

bundle exec middleman build --parallel $*
rm -rf build/agents && cp -R agents build/agents
