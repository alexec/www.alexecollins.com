#!/bin/sh
set -eux
rsync -avz --rsync-path="sudo rsync" build/ deploy@alexecollins.com:/var/www/alexecollins.com/

