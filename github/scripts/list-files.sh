#!/usr/bin/env bash
# List every file on a branch (no local clone needed), one path per line.
# Usage: list-files.sh [BRANCH]
#   BRANCH defaults to the repo's default branch.
# Assumes GITHUB_TOKEN is already exported; repo from $GITHUB_REPO or the origin remote.
REPO=$("$(dirname "$0")/repo-slug.sh") || exit 1
API="https://api.github.com/repos/${REPO}"
HDR=(-H "Authorization: Bearer ${GITHUB_TOKEN}" -H 'Accept: application/vnd.github+json' -H 'X-GitHub-Api-Version: 2022-11-28')

BRANCH="${1:-$(curl -s "${HDR[@]}" "${API}" \
  | python3 -c 'import json,sys; print(json.load(sys.stdin).get("default_branch", "main"))')}"

curl -s "${HDR[@]}" "${API}/git/trees/${BRANCH}?recursive=1" \
  | python3 -c 'import json,sys
d = json.load(sys.stdin)
if "tree" not in d:
    sys.exit("GitHub error: " + d.get("message", "?"))
for t in d["tree"]:
    if t["type"] == "blob":
        print(t["path"])
if d.get("truncated"):
    print("(tree truncated: repo too large for one response)", file=sys.stderr)'
