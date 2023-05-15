import json
import os
import requests
import sys


if len(sys.argv) < 3:
    print(f"Usage python archi-repo.py ORG_NAME REPO_NAME GITHUB_TOKEN [ARCHIVE(1|0) default 1]")

ORG_NAME = sys.argv[1]
REPO_NAME = sys.argv[2]
GITHUB_TOKEN = sys.argv[3]
ARCHIVE = "1" if len(sys.argv) < 5 else sys.argv[4]
if ARCHIVE not in ["0", "1"]:
    print(f"ARCHIVE must be 0 or 1, got {ARCHIVE}")
    sys.exit(1)

archive = ARCHIVE == "1"

headers = {
    "accept": "application/vnd.github+json",
    "owner": ORG_NAME,
    "repo": REPO_NAME,
    "Authorization": f"token {GITHUB_TOKEN}"
}

data = {
    "archived": archive
}
# Define URL to archive repo with API
url = f"https://api.github.com/repos/{ORG_NAME}/{REPO_NAME}"

if archive:
    print(f"Archiving repo {ORG_NAME}/{REPO_NAME}")
else:
    print(f"Unarchiving repo {ORG_NAME}/{REPO_NAME}")

response = requests.patch(url, headers=headers, data=json.dumps(data))
data = response.json()
# The response do not tell if the action ran successfully, it just
# returns the current state of the repo
# print(f" response {data}")
if data['archived'] == archive:
    if archive:
        print("Repo archived successfully")
    else:
        print("Repo unarchived successfully")
