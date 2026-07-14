#!/usr/bin/env python3
"""Format raw GitHub REST JSON (read from stdin) into compact, readable text.

Usage:
    ... | gh-fmt.py prs       # a pull-request list: one row per PR
    ... | gh-fmt.py pr        # a single pull request, with its body
    ... | gh-fmt.py comments  # an issue-comment / review list
    ... | gh-fmt.py posted    # a just-created comment/review/PR: confirm with its URL
"""
import sys
import json


def pr_state(pr):
    if pr.get("merged_at") or pr.get("merged"):
        return "merged"
    if pr.get("draft"):
        return "draft"
    return pr.get("state", "?")


def fmt_prs(data):
    if not data:
        return "No pull requests."
    rows = []
    for pr in data:
        rows.append("\t".join([
            f"#{pr.get('number', '?')}",
            pr_state(pr),
            (pr.get("user") or {}).get("login", "?"),
            f"{(pr.get('head') or {}).get('ref', '?')} -> {(pr.get('base') or {}).get('ref', '?')}",
            pr.get("title", ""),
        ]))
    return "\n".join(rows)


def fmt_pr(data):
    body = (data.get("body") or "").strip()
    return "\n".join([
        f"#{data.get('number', '?')}  {data.get('title', '')}",
        f"State:    {pr_state(data)}",
        f"Author:   {(data.get('user') or {}).get('login', '?')}",
        f"Branches: {(data.get('head') or {}).get('ref', '?')} -> {(data.get('base') or {}).get('ref', '?')}",
        f"URL:      {data.get('html_url', '')}",
        "",
        body if body else "(no description)",
    ])


def fmt_comments(data):
    if not data:
        return "No comments."
    rows = []
    for c in data:
        author = (c.get("user") or {}).get("login", "?")
        when = (c.get("submitted_at") or c.get("created_at") or "")[:10]
        # Reviews carry an event state (APPROVED, CHANGES_REQUESTED, ...); plain comments don't.
        state = c.get("state", "")
        tag = f" [{state}]" if state else ""
        body = (c.get("body") or "").strip()
        rows.append(f"{author} ({when}){tag}: {body if body else '(no text)'}")
    return "\n\n".join(rows)


def fmt_posted(data):
    state = data.get("state", "")
    tag = f" [{state}]" if state else ""
    return f"Posted{tag}: {data.get('html_url', '(no url returned)')}"


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "prs"
    data = json.load(sys.stdin)
    # Surface API errors plainly instead of formatting an empty result.
    if isinstance(data, dict) and data.get("message") and data.get("documentation_url"):
        # The errors array mixes objects and bare strings.
        errors = "; ".join(e.get("message", json.dumps(e)) if isinstance(e, dict) else str(e)
                           for e in data.get("errors", []))
        print("GitHub error: " + data["message"] + (f" ({errors})" if errors else ""), file=sys.stderr)
        sys.exit(1)
    fmt = {"prs": fmt_prs, "pr": fmt_pr, "comments": fmt_comments, "posted": fmt_posted}[mode]
    print(fmt(data))


if __name__ == "__main__":
    main()
