#!/bin/bash

# Post process a specific static site to fix ALL html files.
# The site will be downloaded from oki-archive, changed locally and uploaded again

set -e

BUCKET_NAME=$1

if [ -z $BUCKET_NAME ]; then
    echo "Usage: ./post_process_site.sh BUCKET_NAME"
    exit 1
fi

./check_gcloud_login.sh

echo "Getting all files from $BUCKET_NAME"
mkdir $BUCKET_NAME
gsutil -m cp -r gs://$BUCKET_NAME .

# Custom changes for the site
find $BUCKET_NAME -type f -name "*.html*" -print0 | xargs -0 sed -ri "s/<body(.*)>/<body\1><div style=\"text-align:center;font-size: 120%; background: #fbe9b3; padding: 10px; color: black; z-index: 100; position: absolute; width: 100%;\">This is an archived project from the Open Knowledge Foundation and it is no longer active. For any questions please contact admin at okfn.org.<\/div>/g"
find $BUCKET_NAME -type f -name "*.html*" -print0 | xargs -0 sed -ri "s/<header id=\"header\">/<header id=\"header\" style=\"margin-top:50px\">/g"
find $BUCKET_NAME -type f -name "*.html*" -print0 | xargs -0 sed -ri "/  var _gaq(.*)/,/(.*)\}\)\(\)/ d"
find $BUCKET_NAME -type f -name "*.html*" -print0 | xargs -0 sed -ri "s/<script(.*)consent.js(.*)<\/script>//g"
find $BUCKET_NAME -type f -name "*.html*" -print0 | xargs -0 sed -ri "s/analyticsTrackingID: (.*)//g"

echo "Re-upload all files"
gsutil -m cp -r $BUCKET_NAME/** gs://$BUCKET_NAME
