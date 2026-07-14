# claude-skills
A collection of claude skills.

# GitHub

GitHub skill requires the following environmental variables to be set.

```sh
export GITHUB_TOKEN="ghp_my-personal-access-token"  # needs repo / pull-request scopes
export GITHUB_REPO="owner/repo"                     # optional; defaults to the origin remote
```

Uses only `git`, `curl`, and `python3` (no `gh` CLI), so the same calls port directly
to a JVM: JGit for the git operations, and `java.net.http` (or the
[hub4j github-api](https://github.com/hub4j/github-api) library) for the REST calls.

# Jira

Jira skill requires the following environmental variables to be set.  

```sh
export JIRA_TOKEN="my-secret-token"
export JIRA_EMAIL="my-jira-user@email.com"
export JIRA_CLOUDID="my-jira-cloud-id"    #curl -s "https://${JIRA_SITE_URL}/_edge/tenant_info"
export JIRA_SITE_URL="mysite.atlassian.net"
```
