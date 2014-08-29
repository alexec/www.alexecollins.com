#! /bin/sh
set -eux

git pull
middleman build
rm -Rf /usr/share/nginx/html
mv build /usr/share/nginx/html
