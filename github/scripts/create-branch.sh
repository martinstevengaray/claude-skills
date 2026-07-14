#!/usr/bin/env bash
# Create a branch on GitHub (no local clone needed).
# Usage: create-branch.sh NEW_BRANCH [FROM_BRANCH]
#   FROM_BRANCH defaults to the repo's default branch.
# Assumes GITHUB_TOKEN is already exported; repo from $GITHUB_REPO or the origin remote.
REPO=$("$(dirname "$0")/repo-slug.sh") || exit 1
BRANCH="${1:?usage: create-branch.sh NEW_BRANCH [from-branch]}"
API="https://api.github.com/repos/${REPO}"
HDR=(-H "Authorization: Bearer ${GITHUB_TOKEN}" -H 'Accept: application/vnd.github+json' -H 'X-GitHub-Api-Version: 2022-11-28')

FROM="${2:-$(curl -s "${HDR[@]}" "${API}" \
  | python3 -c 'import json,sys; print(json.load(sys.stdin).get("default_branch", "main"))')}"
SHA=$(curl -s "${HDR[@]}" "${API}/git/ref/heads/${FROM}" \
  | python3 -c 'import json,sys; d=json.load(sys.stdin); sha=(d.get("object") or {}).get("sha"); print(sha) if sha else sys.exit("GitHub error: " + d.get("message", "?"))') || exit 1

python3 -c 'import json,sys; print(json.dumps({"ref": "refs/heads/" + sys.argv[1], "sha": sys.argv[2]}))' "${BRANCH}" "${SHA}" \
  | curl -s "${HDR[@]}" -X POST --data @- "${API}/git/refs" \
  | python3 -c 'import json,sys; d=json.load(sys.stdin); r=d.get("ref"); print("Created " + r + " at " + d["object"]["sha"][:7]) if r else sys.exit("GitHub error: " + d.get("message", "?"))'
