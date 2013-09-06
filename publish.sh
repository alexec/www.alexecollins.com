#!/bin/sh
set -ue

middleman build
rsync -rv --delete build/ ec2:build
