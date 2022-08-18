import csv
import json
import os
import requests
import sys


if len(sys.argv) < 3:
    print(f"Usage python get-all-org-repos.py ORG_NAME GITHUB_TOKEN")

ORG_NAME=sys.argv[1]
GITHUB_TOKEN=sys.argv[2]

repo_list_file = f"repos-{ORG_NAME}.json"
if os.path.exists(repo_list_file):
    print("Repositories list file already exist, IGNORING download")
    results = json.load(open(repo_list_file))
else:
    headers = {
        "Accept": "application/vnd.github+json",
        "Authorization": f"token {GITHUB_TOKEN}"
    }

    per_page = 100
    params = {
        "per_page": per_page,
        "page": 1
    }

    url = f"https://api.github.com/orgs/{ORG_NAME}/repos"

    results = []

    while url:
        print(f"Downloading page {params['page']}")
        response = requests.get(url, headers=headers, params=params)
        data = response.json()
        if len(data) < per_page:
            url = None
        print(f" - {len(data)} results")
        params["page"] += 1
        results += data

    f = open(repo_list_file, "w")
    f.write(json.dumps(results, indent=4))
    f.close()

# Analyze results
print("Analyzing results")
f = open(f"report-{ORG_NAME}.csv", "w")
fieldnames = [
    'name', 'owner', 'is fork', 'created at', 'updated at', 'pushed at', 'stars',
    'archived', 'visibility', 'forks', 'url'
]
report = csv.DictWriter(f, fieldnames=fieldnames)

report.writeheader()
    
for repo in results:
    report.writerow(
        {
            'name': repo["name"],
            'owner': repo["owner"]["login"],
            'is fork': repo["fork"],
            'created at': repo["created_at"],
            'updated at': repo["updated_at"],
            'pushed at': repo["pushed_at"],
            'stars': repo["stargazers_count"],
            'archived': repo["archived"],
            'visibility': repo["visibility"],
            'forks': repo["forks"],
            'url': repo["html_url"]
        }
    )