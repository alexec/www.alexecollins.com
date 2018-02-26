#!/bin/sh
set -eux
cd $(dirname $0)
rsync -avz --rsync-path="sudo rsync" build/ deploy@alexecollins.com:/var/www/alexecollins.com/

