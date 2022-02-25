#!/bin/bash

GCLOUD_ACCOUNT=sysadmin@okfn.org
CURRENT_GCLOUD_ACCOUNT=`gcloud config list account --format "value(core.account)"`

if [ "$CURRENT_GCLOUD_ACCOUNT" != "$GCLOUD_ACCOUNT" ]; then
    echo "✗ You must be logged in as $GCLOUD_ACCOUNT. Use 'gcloud auth login' to login"
    exit 1
else
    echo "✓ Logged in as $GCLOUD_ACCOUNT"
fi
