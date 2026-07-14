#!/usr/bin/env bash
# Submit an approving review on a pull request (optionally with a comment).
# Usage: approve-pr.sh PR_NUMBER ["Review comment"]
# Assumes GITHUB_TOKEN is already exported; repo from $GITHUB_REPO or the origin remote.
# Note: GitHub rejects approving your own PR.
REPO=$("$(dirname "$0")/repo-slug.sh") || exit 1
NUM="${1:?usage: approve-pr.sh PR_NUMBER [\"comment\"]}"
COMMENT="${2:-}"

python3 -c 'import json,sys; print(json.dumps({"event": "APPROVE", "body": sys.argv[1]}))' "${COMMENT}" \
  | curl -s -H "Authorization: Bearer ${GITHUB_TOKEN}" \
      -H 'Accept: application/vnd.github+json' -H 'X-GitHub-Api-Version: 2022-11-28' \
      -X POST --data @- "https://api.github.com/repos/${REPO}/pulls/${NUM}/reviews" \
  | python3 "$(dirname "$0")/gh-fmt.py" posted
