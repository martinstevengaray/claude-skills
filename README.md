# claude-skills
A collection of claude skills

Jira skill requires the four environmental variables to be set
JIRA_TOKEN, JIRA_EMAIL, JIRA_CLOUDID, JIRA_SITE_URL

Example source config.sh script:

```sh
export JIRA_TOKEN="my-secret-token"
export JIRA_EMAIL="my-jira-user@email.com"
export JIRA_CLOUDID="my-jira-cloud-id"    #curl -s "https://${JIRA_SITE_URL}/_edge/tenant_info"
export JIRA_SITE_URL="mysite.atlassian.net"
```
