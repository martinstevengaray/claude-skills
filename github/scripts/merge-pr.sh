#!/usr/bin/env bash
# Merge a pull request.
# Usage: merge-pr.sh PR_NUMBER [merge|squash|rebase] ["Commit title"]
#   Method defaults to "merge". Commit title defaults to GitHub's standard one.
# Assumes GITHUB_TOKEN is already exported; repo from $GITHUB_REPO or the origin remote.
# Fails cleanly if the PR is not mergeable (conflicts, failing required checks, ...).
REPO=$("$(dirname "$0")/repo-slug.sh") || exit 1
NUM="${1:?usage: merge-pr.sh PR_NUMBER [merge|squash|rebase] [\"commit title\"]}"
METHOD="${2:-merge}"
TITLE="${3:-}"

python3 -c 'import json,sys
payload = {"merge_method": sys.argv[1]}
if sys.argv[2]: payload["commit_title"] = sys.argv[2]
print(json.dumps(payload))' "${METHOD}" "${TITLE}" \
  | curl -s -H "Authorization: Bearer ${GITHUB_TOKEN}" \
      -H 'Accept: application/vnd.github+json' -H 'X-GitHub-Api-Version: 2022-11-28' \
      -X PUT --data @- "https://api.github.com/repos/${REPO}/pulls/${NUM}/merge" \
  | python3 -c 'import json,sys
d = json.load(sys.stdin)
if not d.get("merged"): sys.exit("GitHub error: " + d.get("message", "?"))
print("Merged: " + d["sha"][:7] + " (" + d.get("message", "") + ")")'
