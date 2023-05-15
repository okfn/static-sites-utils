# Archive old GitHub repositories

With a GitHub token you'll be able to run api.github.com requests.  
References:
 - Creating access token: https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token
 - Create a token for your user (including organizations) https://github.com/settings/personal-access-tokens/new
 - Fine grained permission URLs: https://docs.github.com/en/rest/overview/permissions-required-for-fine-grained-personal-access-tokens?apiVersion=2022-11-28#administration
 - `PATCH` to update a repository https://docs.github.com/en/rest/repos/repos#update-a-repository

# Required grained permission: Administration repo

## Scan all GitHub repositories within an organization.  

```
python get-all-org-repos.py $ORG_NAME $GHG_TOKEN
```

## Archive a repository

```
python archive-repo.py $ORG_NAME $REPO_NAME $GHG_TOKEN
```

## Unarchive a repository

```
python archive-repo.py $ORG_NAME $REPO_NAME $GHG_TOKEN 0
```
