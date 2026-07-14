#!/usr/bin/env bash
# Print the target repo as "owner/repo": $GITHUB_REPO if set, else parsed from the origin remote.
if [ -n "${GITHUB_REPO}" ]; then
  echo "${GITHUB_REPO}"
  exit 0
fi
slug=$(git remote get-url origin 2>/dev/null \
  | sed -E 's#^(git@github\.com:|https://github\.com/|ssh://git@github\.com/)##; s#\.git$##')
if [ -z "${slug}" ]; then
  echo "Cannot determine repo: set GITHUB_REPO=owner/repo or run inside a clone with a github.com origin remote." >&2
  exit 1
fi
echo "${slug}"
