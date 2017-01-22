#!/bin/sh
set -eux
rsync -a build/ alexecollins.com:/var/www/html/

