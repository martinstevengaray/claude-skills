#!/usr/bin/env bash
# Verify GitHub auth: prints the authenticated user's login.
# Assumes GITHUB_TOKEN is already exported.
curl -s -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  -H 'Accept: application/vnd.github+json' -H 'X-GitHub-Api-Version: 2022-11-28' \
  "https://api.github.com/user" \
  | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("login") or "Auth failed: " + d.get("message", "unknown error"))'
