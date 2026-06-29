---
name: jira
description: Query Jira issues. Use whenever asked to list, read, or search Jira issues/tasks/stories here.
---

# Querying Jira

The scripts assume the four connection env vars are already exported
`JIRA_TOKEN`, `JIRA_EMAIL`, `JIRA_CLOUDID`, and `JIRA_SITE_URL`



| Task | Command |
|------|---------|
| List tasks assigned to the user | `scripts/list-my-tasks.sh` |
| Read one issue | `scripts/get-issue.sh task-key` |
| get-cloud-id.sh | `scripts/get-cloud-id.sh` |
| Verify auth | `scripts/auth-check.sh` |

`list-my-tasks.sh` and `get-issue.sh` emit compact text (via `scripts/jira-fmt.py`),
not raw JSON: a `KEY  STATUS  PRIORITY  SUMMARY` table, and a single issue with its
ADF description already flattened to plain text. 




