#! /bin/sh
set -eux

gsutil -m rsync -R build gs://www.alexecollins.com
gsutil -m acl ch -u AllUsers:r -r gs://www.alexecollins.com/

