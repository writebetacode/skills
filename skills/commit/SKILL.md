---
name: commit
description: Commit staged changes as a ticket-scoped conventional commit. Use whenever the user asks to commit.
---

Commit only what's staged; never stage. Nothing staged → say so and stop. Else invoke the `voice` skill (once per session), then write:

```
<type>(<ticket>): <summary>

- <why>

Co-Authored-By: <model, e.g. Claude Opus 5.5>, ${CLAUDE_EFFORT} effort, <today, YYYY-MM-DD>
```

- Subject ≤80 chars with prefix; summary starts with a capital.
- Skill, agent or prompt `.md` changes are code: `feat`/`fix`, never `docs`.
- Removes or renames something people rely on that the last release tag has → `!` before `:`; a bullet says what breaks. Added since that tag, or no tag → not breaking.
- Ticket: key or number at the branch start or right after its type: `feat/abc-123-x` → `ABC-123`, `feat-123` → `#123`, `fix/login-142` → none. None → drop `(<ticket>)`.
- ≤5 bullets, ≤80 chars each, why only:
  - ✗ `- Add retry to fetchOrders`
  - ✓ `- Survive the payment API's 502s mid-deploy`
- No other trailer.
