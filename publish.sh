#!/bin/sh
set -ue

git push

ssh ec2 <<'ENDSSH'
set -eux
sudo su -
cd www.alexecollins.com
./build.sh
ENDSSH
