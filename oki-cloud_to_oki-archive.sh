#!/bin/bash
#
# Move a bucket from oki-cloud to oki-archive
#

set -e

BUCKET_NAME=$1
BUCKET_TEMP_NAME=`echo "$BUCKET_NAME" | sed -r "s/\./-/g"`

if [ -z $BUCKET_NAME ]; then
    echo "Usage: ./oki-cloud_to_oki-archive.sh BUCKET_NAME"
    exit 1
fi

echo "Check gcloud credentials"
./check_gcloud_login.sh

echo "Create temp bucket in oki-archive"
gsutil mb -l eu -p oki-archive gs://$BUCKET_TEMP_NAME

echo "Copy contents from oki-cloud to oki-archive"
gsutil -m rsync -r gs://$BUCKET_NAME gs://$BUCKET_TEMP_NAME

echo "Delete bucket from oki-cloud"
gsutil -m rm -r gs://$BUCKET_NAME

echo "Create bucket with proper name in oki-archive"
gsutil mb -l eu -p oki-archive gs://$BUCKET_NAME

echo "Copy contents from temp bucket to final one"
gsutil -m rsync -r gs://$BUCKET_TEMP_NAME gs://$BUCKET_NAME

echo "Remove temp bucket"
gsutil -m rm -r gs://$BUCKET_TEMP_NAME
