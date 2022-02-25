#!/bin/bash

set -e

BUCKET_NAME=$1

if [ -z $BUCKET_NAME ]; then
    echo "Usage: ./process_index.html.sh BUCKET_NAME"
    exit 1
fi

./check_gcloud_login.sh

echo "Getting index.html file from $BUCKET_NAME"
gsutil cp gs://$BUCKET_NAME/index.html .

echo "Add archived banner"
sed -ri "s/<body(.*)>/<body\1><div style=\"text-align:center;font-size: 120%; background: #fbe9b3; padding: 10px; color: black\">This is an archived project from the Open Knowledge Foundation and it is no longer active. For any questions please contact admin at okfn.org.<\/div>/g" index.html

echo "Remove Google Analytics"
sed -ri "s/<script(.*)consent.js(.*)<\/script>//g" index.html
sed -ri "s/analyticsTrackingID: (.*)//g" index.html

echo "Re-upload file"
gsutil cp index.html gs://$BUCKET_NAME/index.html
