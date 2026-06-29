#!/usr/bin/env bash
# Fetch the Atlassian cloud ID for the site. Assumes JIRA_SITE_URL is exported.
curl -s "https://${JIRA_SITE_URL}/_edge/tenant_info"
