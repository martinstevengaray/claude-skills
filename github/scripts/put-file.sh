#!/usr/bin/env bash
# Commit one file to a branch on GitHub (no local clone needed).
# Creates the file if it doesn't exist, updates it if it does.
# Usage: put-file.sh REPO_PATH LOCAL_FILE [BRANCH] ["Commit message"]
#   BRANCH defaults to the repo's default branch.
# Assumes GITHUB_TOKEN is already exported; repo from $GITHUB_REPO or the origin remote.
# Note: one file per commit; for a multi-file atomic commit use put-files.sh.
REPO=$("$(dirname "$0")/repo-slug.sh") || exit 1
REPO_PATH="${1:?usage: put-file.sh REPO_PATH LOCAL_FILE [branch] [\"message\"]}"
LOCAL_FILE="${2:?usage: put-file.sh REPO_PATH LOCAL_FILE [branch] [\"message\"]}"
BRANCH="${3:-}"
MESSAGE="${4:-Update ${REPO_PATH}}"
[ -r "${LOCAL_FILE}" ] || { echo "Cannot read local file: ${LOCAL_FILE}" >&2; exit 1; }
API="https://api.github.com/repos/${REPO}"
HDR=(-H "Authorization: Bearer ${GITHUB_TOKEN}" -H 'Accept: application/vnd.github+json' -H 'X-GitHub-Api-Version: 2022-11-28')

# Existing file -> we must send its blob SHA (optimistic lock); missing file -> create.
fetch_sha() {
  curl -s "${HDR[@]}" "${API}/contents/${REPO_PATH}${BRANCH:+?ref=${BRANCH}}" \
    | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("sha", ""))'
}

do_put() {
  python3 -c 'import json,sys,base64
payload = {"message": sys.argv[2], "content": base64.b64encode(open(sys.argv[1], "rb").read()).decode()}
if sys.argv[3]: payload["sha"] = sys.argv[3]
if sys.argv[4]: payload["branch"] = sys.argv[4]
print(json.dumps(payload))' "${LOCAL_FILE}" "${MESSAGE}" "$1" "${BRANCH}" \
    | curl -s "${HDR[@]}" -X PUT --data @- "${API}/contents/${REPO_PATH}"
}

SHA=$(fetch_sha)
RESULT=$(do_put "${SHA}")
# The contents GET can briefly 404 for a file committed moments ago; if GitHub
# then rejects the create for lacking a sha, re-fetch it and retry once.
if [ -z "${SHA}" ] && printf '%s' "${RESULT}" | grep -q 'sha.*supplied'; then
  sleep 2
  SHA=$(fetch_sha)
  RESULT=$(do_put "${SHA}")
fi

printf '%s' "${RESULT}" | python3 -c 'import json,sys
d = json.load(sys.stdin)
c = d.get("commit")
if not c: sys.exit("GitHub error: " + d.get("message", "?"))
print("Committed " + c["sha"][:7] + ": " + c["html_url"])'
