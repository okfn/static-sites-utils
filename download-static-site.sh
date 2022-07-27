#!/bin/bash
#
# Download a static version of a site
# Create a bucket and upload these files
# Make the contents of a bucket public on the internet and
# create a DNS record for it
#

set -e
DOMAIN_NAME=$1
PROTOCOL=$2
ALREADY_DOWNLOADED=${3:-false}

if [ -z $DOMAIN_NAME ]; then
    echo "Usage: ./download-static-site.sh DOMAIN_NAME [PROTOCOL (http | https)]"
    exit 1
fi

if [ -z $PROTOCOL ]; then
     PROTOCOL="http"
fi

if [ $ALREADY_DOWNLOADED = "false" ]; then
     echo "Downloading $DOMAIN_NAME ..."
     URL="$PROTOCOL://$DOMAIN_NAME"

     wget \
          -t 2 \
          --recursive \
          --no-clobber \
          --page-requisites \
          --html-extension \
          --convert-links \
          --restrict-file-names=windows \
          --domains $DOMAIN_NAME \
          --no-parent $URL
fi

BUCKET_NAME=$DOMAIN_NAME

echo "Check gcloud credentials"
./check_gcloud_login.sh

echo "Check if bucket '$BUCKET_NAME' exists"
BUCKET_EXIST=`gsutil ls -L -b gs://$BUCKET_NAME` || BUCKET_EXIST=false
echo " - BUCKET_EXIST = '$BUCKET_EXIST'"
if [ "$BUCKET_EXIST" = "false" ]; then
    echo "Bucket don't exits, creating the bucket in oki-archive"
    gsutil mb -l eu -p oki-archive gs://$BUCKET_NAME
else
    echo "Bucket is located in oki-archive"
fi

echo "Updating http to https in all site files"
find ./$DOMAIN_NAME -type f -print0 | xargs -0 sed -i 's/http:\/\//https:\/\//g'

echo "Removing all 'login' links"
find ./$DOMAIN_NAME -type f -print0 | xargs -0 sed -ri "s/<a\ (.*)>Login(.*)<\/a>//g"

echo "Upload files"
gsutil -m cp -r $DOMAIN_NAME/** gs://$BUCKET_NAME

echo "Set public permissions"
gsutil iam ch allUsers:objectViewer gs://$BUCKET_NAME

echo "Set website properties"
gsutil web set -m index.html gs://$BUCKET_NAME

echo "Modify index.html"
./process_index.html.sh $BUCKET_NAME

# Avoid conflict with the "update_cname_records" script
echo "Delete local folder"
rm -rf $DOMAIN_NAME

echo "Set up CNAME record"
python update_cname_records.py $BUCKET_NAME
