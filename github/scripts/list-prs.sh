#!/usr/bin/env bash
# List pull requests as: #NUM  STATE  AUTHOR  HEAD->BASE  TITLE
# Usage: list-prs.sh [open|closed|all]   (default: open)
# Assumes GITHUB_TOKEN is already exported; repo from $GITHUB_REPO or the origin remote.
REPO=$("$(dirname "$0")/repo-slug.sh") || exit 1
STATE="${1:-open}"
curl -s -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  -H 'Accept: application/vnd.github+json' -H 'X-GitHub-Api-Version: 2022-11-28' \
  "https://api.github.com/repos/${REPO}/pulls?state=${STATE}&per_page=50" \
  | python3 "$(dirname "$0")/gh-fmt.py" prs
