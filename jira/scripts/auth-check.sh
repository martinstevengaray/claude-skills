#!/usr/bin/env bash
# Verify Jira auth.
# Assumes JIRA_TOKEN, JIRA_EMAIL, and JIRA_CLOUDID are already exported.
JIRA_API="https://api.atlassian.com/ex/jira/${JIRA_CLOUDID}/rest/api/3"
curl -s -u "${JIRA_EMAIL}:${JIRA_TOKEN}" -H 'Accept: application/json' \
  "${JIRA_API}/myself"
