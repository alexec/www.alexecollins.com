#!/bin/sh
set -ue

ssh ec2 <<'ENDSSH'
set -eux
sudo su -
cd www.alexecollins.com
./build.sh
ENDSSH
