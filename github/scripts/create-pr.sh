#!/usr/bin/env bash
# Open a pull request.
# Usage: create-pr.sh "Title" [HEAD_BRANCH] [BASE_BRANCH] ["Body text"]
#   HEAD_BRANCH defaults to the current local branch (requires a clone).
#   BASE_BRANCH defaults to the repo's default branch.
# Assumes GITHUB_TOKEN is already exported; repo from $GITHUB_REPO or the origin remote.
# The head branch must already exist on GitHub.
REPO=$("$(dirname "$0")/repo-slug.sh") || exit 1
TITLE="${1:?usage: create-pr.sh \"Title\" [head-branch] [base-branch] [\"body\"]}"
API="https://api.github.com/repos/${REPO}"
HDR=(-H "Authorization: Bearer ${GITHUB_TOKEN}" -H 'Accept: application/vnd.github+json' -H 'X-GitHub-Api-Version: 2022-11-28')

HEAD_BRANCH="${2:-$(git branch --show-current 2>/dev/null)}"
[ -n "${HEAD_BRANCH}" ] || { echo "No head branch: pass one, or run inside a clone." >&2; exit 1; }
BASE="${3:-$(curl -s "${HDR[@]}" "${API}" \
  | python3 -c 'import json,sys; print(json.load(sys.stdin).get("default_branch", "main"))')}"
BODY="${4:-}"

python3 -c 'import json,sys; print(json.dumps({"title": sys.argv[1], "head": sys.argv[2], "base": sys.argv[3], "body": sys.argv[4]}))' \
    "${TITLE}" "${HEAD_BRANCH}" "${BASE}" "${BODY}" \
  | curl -s "${HDR[@]}" -X POST --data @- "${API}/pulls" \
  | python3 "$(dirname "$0")/gh-fmt.py" pr
