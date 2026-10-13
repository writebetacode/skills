---
name: ticket
description: Create, view, edit, comment on, assign, link, close or reopen tickets: GitHub or GitLab issues and Jira work items. Use when asked to file, open, log or write up a bug, feature or task as a ticket, issue or work item, or to change, comment on, link or close one.
---

Tracker, first match:

1. Jira key (`ABC-123`) → Jira. GitHub/GitLab URL or a named tracker → that one.
2. Ticket at the branch start or right after its type: `feat/abc-123-x` → Jira, `feat/123-x` → origin's host.
3. Bare `#123` → origin's host.
4. Else ask once, offering origin's host: "GitHub (acme/shop)?". Never pick it silently.

Origin's host: `origin` URL contains `github` → GitHub, `gitlab` → GitLab; else whichever of `gh repo view` / `glab repo view` succeeds; both or neither → ask. Read [github.md](github.md), [gitlab.md](gitlab.md) or [jira.md](jira.md); run remote commands only from its table.

Any write (create, edit, comment, assign, link, close, reopen) → read [write.md](write.md) first.
