# Open Knowledge Infrastructure - Static sites utilities

A collection of scripts and documentation to help archive old websites as static sites.

## Context

Old, unmaintained sites that are part of the OKF infrastucture should be migrated to static versions that can be hosted cheapily and without requiring further maitenance.

### Goals

* All archived sites should be stored as buckets in Google Cloud Storage,under the `oki-archive` project.
* There should be no unused items left after archiving a site, including active Wordpress sites, databases or DNS records
* Archived sites should display a banner stating the site is no longer active and providing a contact address

### Services / Where and how to login

To perform the tasks described below you might need access to the following services:

* [Cloudflare](https://dash.cloudflare.com): For managing DNS records. Log in as *sysadmin at okfn.org*, the password is on LastPass. You will need to access the sysadmin at okfn.org Gmail inbox to get the 2FA token. To access this inbox you will need the password stored on LastPass and a 2FA code from the Google Authenticator app.
* [Google Cloud Storage](https://console.cloud.google.com/storage/browser?authuser=1&project=oki-archive&prefix=): For managing the Storage buckets. While you can use your own *@okfn.org* account to browse the UI, to perform the actual tasks from the scripts you will need to login locally as *sysadmin at okfn.org* using `gcloud auth login`.
* Wordpress. For managing (shutting down) WP sites. Use your *@okfn.org* account to login to one of the network site admin pages, eg:
    * https://core.okfn.org/wp-admin/network/sites.php
    * https://network.okfn.org/wp-admin/network/sites.php
    * https://websites.okfn.org/wp-admin/network/sites.php
    * https://scoda.okfn.org/wp-admin/network/sites.php


### Process

*Note:* this process is heavily biased towards the archival of old Wordpress sites from the blogfarm, but the same principles should be applied to any static site.

The overall process is:

1. Create a bucket in Google Cloud Storage (`oki-archive` project) with the contents of the static, with the same name as the domain that the page will be published with, eg `openeconomics.net`, `design.okfn.org` etc
2. Set up the necessary permissions to make it public
3. Modify the index.html to add a notice banner and re-upload
4. Modify the DNS records on Cloudflare to point to the bucket
5. Clean up: remove unneeded DNS records and archive old sites in Wordpress

All these steps except the last one are automated with the scripts included in this repository, but of course different sites can have specific needs so you might need to adapt them to your needs.

## Scripts 

### Requirements

To run these scripts you will need to install:

* The `gcloud` CLI ([Installation](https://cloud.google.com/sdk/docs/install))
* The Google Cloud Storage `gsutil` CLI ([Installation](https://cloud.google.com/storage/docs/gsutil_install))
* A virtualenv with the following packages installed:

      pip install cloudflare tldextract

### Setup

* You need to login to `gcloud` using the *sysadmin@okfn.org* account:

       gcloud auth login

* You need to define your Cloudflare API token. The token is stored in LastPass. Create a new file in `~/.cloudflare.cfg` with the following contents:

       [CloudFlare]
       token=xxxx_token_in_last_pass

### Running 

The main script you probably want to run is `publish_bucket.sh`. Assuming there is an existing bucket named `design.okfn.org`:

    ./publish_bucket.sh design.okfn.org

This is turn will call the following scripts, which you can call individually or mix with others as needed:

| Script name | Description|
|---|---|
| `./check_gcloud_login.sh` | Checks that you are logged in with *sysadmin at okfn.org* |
| `./oki-cloud_to_oki-archive.sh <BUCKET_NAME>` | Moves a bucket from the `oki-cloud` project to `oki-archive` (if needed) |
| `./process_index.html <BUCKET_NAME>` | Downloads the index.html file, adds the deprecation banner, removes the GA script and re-uploads it |
| `python update_cname_records.py <BUCKET_NAME>` | Creates or updates an existing CNAME record to point to GCS |

## License

MIT
