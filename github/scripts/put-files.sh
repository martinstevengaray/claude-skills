#!/usr/bin/env bash
# Commit several files to a branch on GitHub in ONE atomic commit (no local clone
# needed), via the Git Database API: blobs -> tree -> commit -> ref update.
# Usage: put-files.sh BRANCH "Commit message" LOCAL_FILE:REPO_PATH [LOCAL_FILE:REPO_PATH ...]
#   e.g. put-files.sh feat "Add feature" ./Main.java:src/Main.java ./pom.xml:pom.xml
# Assumes GITHUB_TOKEN is already exported; repo from $GITHUB_REPO or the origin remote.
# Paths must not contain ":" (it separates local from repo path). Local executable
# bits are preserved. For a single file, put-file.sh is simpler.
REPO=$("$(dirname "$0")/repo-slug.sh") || exit 1
USAGE='usage: put-files.sh BRANCH "message" LOCAL_FILE:REPO_PATH [...]'
BRANCH="${1:?${USAGE}}"
MESSAGE="${2:?${USAGE}}"
shift 2
[ $# -ge 1 ] || { echo "${USAGE}" >&2; exit 1; }
API="https://api.github.com/repos/${REPO}"
HDR=(-H "Authorization: Bearer ${GITHUB_TOKEN}" -H 'Accept: application/vnd.github+json' -H 'X-GitHub-Api-Version: 2022-11-28')

# Pull one dotted-path field out of a JSON response, or fail with its error message.
extract() {
  python3 -c 'import json,sys
d = json.load(sys.stdin)
cur = d
for k in sys.argv[1].split("."):
    if not isinstance(cur, dict) or k not in cur:
        sys.exit("GitHub error: " + str(d.get("message", d)))
    cur = cur[k]
print(cur)' "$1"
}

HEAD_SHA=$(curl -s "${HDR[@]}" "${API}/git/ref/heads/${BRANCH}" | extract object.sha) || exit 1
BASE_TREE=$(curl -s "${HDR[@]}" "${API}/git/commits/${HEAD_SHA}" | extract tree.sha) || exit 1

# One blob per file, collecting {path, mode, type, sha} tree entries as JSON.
ENTRIES=""
for PAIR in "$@"; do
  LOCAL="${PAIR%%:*}"
  REPO_PATH="${PAIR#*:}"
  [ -r "${LOCAL}" ] || { echo "Cannot read local file: ${LOCAL}" >&2; exit 1; }
  BLOB_SHA=$(python3 -c 'import json,sys,base64
print(json.dumps({"content": base64.b64encode(open(sys.argv[1], "rb").read()).decode(), "encoding": "base64"}))' "${LOCAL}" \
    | curl -s "${HDR[@]}" -X POST --data @- "${API}/git/blobs" | extract sha) || exit 1
  MODE=$([ -x "${LOCAL}" ] && echo 100755 || echo 100644)
  ENTRIES="${ENTRIES}${ENTRIES:+,}$(python3 -c 'import json,sys
print(json.dumps({"path": sys.argv[1], "mode": sys.argv[2], "type": "blob", "sha": sys.argv[3]}))' \
    "${REPO_PATH}" "${MODE}" "${BLOB_SHA}")"
done

NEW_TREE=$(printf '{"base_tree":"%s","tree":[%s]}' "${BASE_TREE}" "${ENTRIES}" \
  | curl -s "${HDR[@]}" -X POST --data @- "${API}/git/trees" | extract sha) || exit 1

NEW_COMMIT=$(python3 -c 'import json,sys
print(json.dumps({"message": sys.argv[1], "tree": sys.argv[2], "parents": [sys.argv[3]]}))' \
    "${MESSAGE}" "${NEW_TREE}" "${HEAD_SHA}" \
  | curl -s "${HDR[@]}" -X POST --data @- "${API}/git/commits" | extract sha) || exit 1

printf '{"sha":"%s"}' "${NEW_COMMIT}" \
  | curl -s "${HDR[@]}" -X PATCH --data @- "${API}/git/refs/heads/${BRANCH}" \
  | extract object.sha > /dev/null || exit 1
echo "Committed ${NEW_COMMIT:0:7} ($# files): https://github.com/${REPO}/commit/${NEW_COMMIT}"
