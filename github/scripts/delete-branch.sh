#!/usr/bin/env bash
# Delete a branch on GitHub.
# Usage: delete-branch.sh BRANCH
# Assumes GITHUB_TOKEN is already exported; repo from $GITHUB_REPO or the origin remote.
REPO=$("$(dirname "$0")/repo-slug.sh") || exit 1
BRANCH="${1:?usage: delete-branch.sh BRANCH}"

# Success is an empty 204, so branch on the status code rather than parsing a body.
BODY=$(curl -s -X DELETE -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  -H 'Accept: application/vnd.github+json' -H 'X-GitHub-Api-Version: 2022-11-28' \
  -w '\n%{http_code}' \
  "https://api.github.com/repos/${REPO}/git/refs/heads/${BRANCH}")
CODE="${BODY##*$'\n'}"
if [ "${CODE}" = "204" ]; then
  echo "Deleted ${BRANCH}"
else
  printf '%s' "${BODY%$'\n'*}" \
    | python3 -c 'import json,sys; sys.exit("GitHub error: " + json.load(sys.stdin).get("message", "?"))'
fi
