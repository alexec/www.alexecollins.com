#! /bin/bash
set -eux

git pull
middleman build
ansible-playbook -i inventory site.yml
