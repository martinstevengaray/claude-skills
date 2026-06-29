#!/usr/bin/env python3
"""Format raw Jira REST JSON (read from stdin) into compact, readable text.

Usage:
    ... | jira-fmt.py issues   # a /search response: one row per issue
    ... | jira-fmt.py issue    # a single-issue response, with ADF -> plain text
"""
import sys
import json

# Block-level ADF nodes after which we want a line break for readability.
_BLOCK_TYPES = {"paragraph", "heading", "listItem", "blockquote", "codeBlock"}


def adf_text(node):
    """Recursively pull plain text out of an Atlassian Document Format tree."""
    if node is None:
        return ""
    if isinstance(node, list):
        return "".join(adf_text(n) for n in node)
    if isinstance(node, dict):
        text = node.get("text", "")
        children = adf_text(node.get("content"))
        sep = "\n" if node.get("type") in _BLOCK_TYPES else ""
        return text + children + sep
    return ""


def fmt_issues(data):
    issues = data.get("issues", [])
    if not issues:
        return "No issues."
    rows = []
    for issue in issues:
        f = issue.get("fields", {})
        rows.append("\t".join([
            issue.get("key", "?"),
            (f.get("status") or {}).get("name", "?"),
            (f.get("priority") or {}).get("name", "-"),
            f.get("summary", ""),
        ]))
    return "\n".join(rows)


def fmt_issue(data):
    f = data.get("fields", {})
    assignee = f.get("assignee") or {}
    desc = adf_text(f.get("description")).strip()
    return "\n".join([
        f"{data.get('key', '?')}  {f.get('summary', '')}",
        f"Status:   {(f.get('status') or {}).get('name', '?')}",
        f"Assignee: {assignee.get('displayName', 'Unassigned')}",
        "",
        desc if desc else "(no description)",
    ])


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "issues"
    data = json.load(sys.stdin)
    # Surface API errors plainly instead of formatting an empty result.
    if isinstance(data, dict) and data.get("errorMessages"):
        print("Jira error: " + "; ".join(data["errorMessages"]), file=sys.stderr)
        sys.exit(1)
    print(fmt_issue(data) if mode == "issue" else fmt_issues(data))


if __name__ == "__main__":
    main()
