#!/usr/bin/env bash
# Read a single Jira issue, with the ADF description rendered as plain text.
# Usage: get-issue.sh SDD-1
# Assumes JIRA_TOKEN, JIRA_EMAIL, and JIRA_CLOUDID are already exported.
KEY="${1:?usage: get-issue.sh <ISSUE-KEY>  e.g. get-issue.sh SDD-1}"
JIRA_API="https://api.atlassian.com/ex/jira/${JIRA_CLOUDID}/rest/api/3"
curl -s -u "${JIRA_EMAIL}:${JIRA_TOKEN}" -H 'Accept: application/json' \
  "${JIRA_API}/issue/${KEY}?fields=summary,status,assignee,description" \
  | python3 "$(dirname "$0")/jira-fmt.py" issue
