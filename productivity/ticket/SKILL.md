---
name: ticket
description: Create, view, edit, comment on, assign, link, close or reopen tickets: GitHub or GitLab issues and Jira work items. Use when asked to file, open, log or write up a bug, feature or task as a ticket, issue or work item, or to change, comment on, link or close one.
---

Tracker, first match:

1. Jira key (`ABC-123`) → Jira. GitHub/GitLab URL or a named tracker → that one.
2. Ticket at the branch start or right after its type: `feat/abc-123-x` → Jira, `feat/123-x` → origin's host.
3. Bare `#123` → origin's host.
4. Else ask once, offering origin's host: "GitHub (acme/shop)?". Never pick it silently.

Origin's host: `origin` URL contains `github`/`gitlab`; else whichever of `gh repo view`/`glab repo view` succeeds. Read [github.md](github.md), [gitlab.md](gitlab.md) or [jira.md](jira.md); run remote commands only from its table.

Content, in titles, bodies, edits and comments: what was seen or is wanted, and why it matters to users. Never how: no causes, code, files or fixes, even when the request names them.

- ✗ `Add a null check in cartTotal()` ✓ `An empty cart's checkout shows 0.00`

Title: GitHub/GitLab `<type>: <Summary>` (`fix`, `feat`, `chore`…); Jira: summary only, type as `--type` (a type the project defines).

Body, exactly; Steps to reproduce for bugs only; Jira: no checkboxes:

```
## Description
<≤3 sentences>
## Steps to reproduce
- <step>
## Acceptance criteria
- [ ] <observable outcome: it's done when…>
```

Links (parent, blocks, blocked by, related): native where the tracker file has a command; else, or when native is rejected, a line at the body's end: `Parent: #40`, `Blocked by: #50`, `Blocks: #53`, `Related: #47`. Building out a parent's children → every child gets its parent. Else links and labels only when asked.

- Draft from the request and context; ask only for a required field you can't derive (Jira project key or type); never invent one.
- Write directly; show a draft first only when asked.
- New tickets: assigned to the user.
- Edits: change only what's named; keep the rest byte-for-byte.
- Bodies and comments → temp file outside the repo.
- One named ticket per write: never delete, never write via a query or filter.
- After a write, show its key or number and URL.
- No AI attribution.
