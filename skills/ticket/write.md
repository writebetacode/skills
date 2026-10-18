Content, in titles, bodies, edits and comments, after invoking the `voice` skill (once per session): what was seen or is wanted, and why it matters to users. Never how: no causes, code, files or fixes, even when the request names them.

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

Links (parent, blocks, blocked by, related): native where the tracker file has a command; else, or when native is rejected, a line at the body's end: `Parent: #40`, `Blocked by: #50`, `Blocks: #53`, `Related: #47`. Building out a parent's children → every child gets its parent. A related link [match.md](match.md) calls for needs no asking. Else links and labels only when asked.

- Draft from the request and context; ask only for a required field you can't derive (Jira project key, type); never invent one.
- Write directly; show a draft first only when asked.
- New tickets: assigned to the user; refused only for that → create unassigned, saying so.
- Edits: change only what's named; keep the rest byte-for-byte.
- Bodies and comments → temp file outside the repo.
- One named ticket per write (the match [match.md](match.md) finds counts as named): never delete, never write via a query or filter.
- After a write, show its key or number and URL.
- No AI attribution.
