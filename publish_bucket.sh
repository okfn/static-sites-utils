#!/bin/bash
#
# Make the contents of a bucket public on the internet and
# create a DNS record for it
#

set -e

BUCKET_NAME=$1
OKI_ARCHIVE_PROJECT_ID=235068597494

if [ -z $BUCKET_NAME ]; then
    echo "Usage: ./publish_bucket.sh BUCKET_NAME"
    exit 1
fi

echo "Check gcloud credentials"
./check_gcloud_login.sh

echo "Check if bucket is in the oki-archive project"
PROJECT_ID=`gsutil ls -L -b gs://$BUCKET_NAME | grep -m 1 projectNumber | awk -F "[\",]" '{print $4}'`
if [ "$PROJECT_ID" != "$OKI_ARCHIVE_PROJECT_ID" ]; then
    echo "Moving bucket to oki-archive"
    ./oki-cloud_to_oki-archive.sh $BUCKET_NAME
else
    echo "✓ Bucket is located in oki-archive"
fi

echo "Set public permissions"
gsutil iam ch allUsers:objectViewer gs://$BUCKET_NAME

echo "Set website properties"
gsutil web set -m index.html gs://$BUCKET_NAME

echo "Modify index.html"
./process_index.html.sh $BUCKET_NAME

echo "Set up CNAME record"
python update_cname_records.py $BUCKET_NAME
