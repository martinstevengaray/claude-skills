#!/usr/bin/env bash
# List Jira issues assigned to the current user, as: KEY  STATUS  PRIORITY  SUMMARY
# Assumes JIRA_TOKEN, JIRA_EMAIL, and JIRA_CLOUDID are already exported.
JIRA_API="https://api.atlassian.com/ex/jira/${JIRA_CLOUDID}/rest/api/3"
curl -s -u "${JIRA_EMAIL}:${JIRA_TOKEN}" -H 'Accept: application/json' \
  --get "${JIRA_API}/search/jql" \
  --data-urlencode 'jql=assignee = currentUser() ORDER BY updated DESC' \
  --data-urlencode 'fields=summary,status,priority,issuetype,project,description' \
  --data-urlencode 'maxResults=50' \
  | python3 "$(dirname "$0")/jira-fmt.py" issues
