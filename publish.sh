#!/bin/sh
set -ue

sh ec2 <<'ENDSSH'
set -eux
sudo su -
cd www.alexecollins.com
./build.sh
ENDSSH
