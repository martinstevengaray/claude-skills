---
name: github
description: Work with GitHub — create branches, commit and push code, open pull requests, and read, comment on, or approve PRs. Use whenever asked to do any of those here.
---

# Working with GitHub

Scripts assume `GITHUB_TOKEN` is already exported. The target repo is taken from
`$GITHUB_REPO` (`owner/repo`) if set, otherwise parsed from the `origin` remote.
No `gh` CLI needed — everything is plain `git` + `curl` against the REST API.

## Branching and committing (plain git)

| Task | Command |
|------|---------|
| Create a branch | `git checkout -b branch-name` |
| Commit | `git add <files>` then `git commit -m "message"` |
| Push branch to GitHub | `git push -u origin branch-name` |

If the remote isn't authenticated (no SSH key / credential helper), push with the token:
`git push https://x-access-token:${GITHUB_TOKEN}@github.com/owner/repo.git branch-name`
(don't save that URL as a remote — it embeds the token).

## Pull requests (REST API scripts)

| Task | Command |
|------|---------|
| Verify auth | `scripts/auth-check.sh` |
| Create a branch on GitHub (no clone needed) | `scripts/create-branch.sh new-branch [from-branch]` |
| Delete a branch on GitHub | `scripts/delete-branch.sh branch-name` |
| List all files on a branch (no clone needed) | `scripts/list-files.sh [branch]` |
| Read one file from a branch (no clone needed) | `scripts/get-file.sh path/to/file [branch]` |
| Commit one file to a branch (no clone needed) | `scripts/put-file.sh repo/path local-file [branch] ["message"]` |
| Commit several files atomically (no clone needed) | `scripts/put-files.sh branch "message" local:repo/path ...` |
| List PRs | `scripts/list-prs.sh [open\|closed\|all]` |
| Read one PR + its comments/reviews | `scripts/get-pr.sh 42` |
| Open a PR | `scripts/create-pr.sh "Title" [head-branch] [base-branch] ["body"]` |
| Comment on a PR | `scripts/comment-pr.sh 42 "comment text"` |
| Approve a PR | `scripts/approve-pr.sh 42 ["optional comment"]` |
| Merge a PR | `scripts/merge-pr.sh 42 [merge\|squash\|rebase] ["commit title"]` |

The scripts emit compact text (via `scripts/gh-fmt.py`), not raw JSON: PR lists as a
`#NUM  STATE  AUTHOR  HEAD->BASE  TITLE` table, single PRs with their description,
comments as `author (date): text`.

Notes:
- `create-pr.sh` head defaults to the current local branch (push it first); pass it
  explicitly for repos without a clone. Base defaults to the repo's default branch.
- GitHub rejects approving your own PR (HTTP 422); the error is printed plainly.
