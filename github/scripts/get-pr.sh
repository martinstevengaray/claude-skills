#!/usr/bin/env bash
# Show one pull request: header, description, then its comments and reviews.
# Usage: get-pr.sh PR_NUMBER
# Assumes GITHUB_TOKEN is already exported; repo from $GITHUB_REPO or the origin remote.
REPO=$("$(dirname "$0")/repo-slug.sh") || exit 1
NUM="${1:?usage: get-pr.sh PR_NUMBER}"
API="https://api.github.com/repos/${REPO}"
HDR=(-H "Authorization: Bearer ${GITHUB_TOKEN}" -H 'Accept: application/vnd.github+json' -H 'X-GitHub-Api-Version: 2022-11-28')
FMT="$(dirname "$0")/gh-fmt.py"

curl -s "${HDR[@]}" "${API}/pulls/${NUM}" | python3 "${FMT}" pr || exit 1
echo
echo "--- Comments ---"
curl -s "${HDR[@]}" "${API}/issues/${NUM}/comments" | python3 "${FMT}" comments
echo
echo "--- Reviews ---"
curl -s "${HDR[@]}" "${API}/pulls/${NUM}/reviews" | python3 "${FMT}" comments
