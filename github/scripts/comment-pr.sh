#!/usr/bin/env bash
# Post a comment on a pull request.
# Usage: comment-pr.sh PR_NUMBER "Comment text"
# Assumes GITHUB_TOKEN is already exported; repo from $GITHUB_REPO or the origin remote.
REPO=$("$(dirname "$0")/repo-slug.sh") || exit 1
NUM="${1:?usage: comment-pr.sh PR_NUMBER \"comment\"}"
COMMENT="${2:?usage: comment-pr.sh PR_NUMBER \"comment\"}"

python3 -c 'import json,sys; print(json.dumps({"body": sys.argv[1]}))' "${COMMENT}" \
  | curl -s -H "Authorization: Bearer ${GITHUB_TOKEN}" \
      -H 'Accept: application/vnd.github+json' -H 'X-GitHub-Api-Version: 2022-11-28' \
      -X POST --data @- "https://api.github.com/repos/${REPO}/issues/${NUM}/comments" \
  | python3 "$(dirname "$0")/gh-fmt.py" posted
