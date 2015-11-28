#! /bin/bash
set -eux

git pull
git status

docker build .
IMAGE=$(docker images | head -n1)
docker run --rm -v build:/www.alexcollins.com/build 
docker rmi -f $IMAGE

gsutil rsync -R build gs://www.alexecollins.com
gsutil -m acl ch -d AllUsers -r gs://www.alexecollins.com/

open http://www.alexecollins.com/