#!/usr/bin/env bash
# Print one file's content from a branch (no local clone needed).
# Usage: get-file.sh PATH [BRANCH]
#   BRANCH defaults to the repo's default branch. Also accepts a tag or commit SHA.
# Assumes GITHUB_TOKEN is already exported; repo from $GITHUB_REPO or the origin remote.
REPO=$("$(dirname "$0")/repo-slug.sh") || exit 1
FILE="${1:?usage: get-file.sh PATH [branch]}"
BRANCH="${2:-}"

# The raw accept header returns the file body directly (no base64 JSON wrapper),
# so errors come back as JSON while success is plain content: split on status code.
BODY=$(curl -s -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  -H 'Accept: application/vnd.github.raw+json' -H 'X-GitHub-Api-Version: 2022-11-28' \
  -w '\n%{http_code}' \
  "https://api.github.com/repos/${REPO}/contents/${FILE}${BRANCH:+?ref=${BRANCH}}")
CODE="${BODY##*$'\n'}"
CONTENT="${BODY%$'\n'*}"
if [ "${CODE}" = "200" ]; then
  printf '%s\n' "${CONTENT}"
else
  printf '%s' "${CONTENT}" \
    | python3 -c 'import json,sys; sys.exit("GitHub error: " + json.load(sys.stdin).get("message", "?"))'
fi
