#! /bin/sh
set -eu

rm -Rf upload
cp -R build upload
cd upload

for F in $(find . -path '*.css' -or -path '*.html' -or -path '*.js'); do
    cat $F | gzip > tmp
    mv tmp $F
done

find . -name tmp | xargs rm -

gsutil web set -m index.html -e 404.html gs://www.alexecollins.com
gsutil -m rsync -R . gs://www.alexecollins.com
gsutil -m acl ch -u AllUsers:r -r gs://www.alexecollins.com/

gsutil -m setmeta -h "Cache-Control:public, max-age=604800" -r gs://www.alexecollins.com/
gsutil -m setmeta -h "Cache-Control:public, max-age=604800" -h "Content-Encoding:gzip" -h "Content-Type:text/css" -r gs://www.alexecollins.com/**.css
gsutil -m setmeta -h "Cache-Control:public, max-age=604800" -h "Content-Encoding:gzip" -h "Content-Type:text/html" -r gs://www.alexecollins.com/**.html
gsutil -m setmeta -h "Cache-Control:public, max-age=604800" -h "Content-Encoding:gzip" -h "Content-Type:text/javascript" -r gs://www.alexecollins.com/**.js
