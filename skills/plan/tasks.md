Tasks from the spec alone: never open `research/`, `findings.md` or tickets; ignore this conversation.

`tasks/NN-<mr>.md`: terse, for an agent. MR = one branch that works and ships alone; MRs merge strictly in NN order, never in parallel. One repo per MR; work spanning repos → one MR per repo, each naming the others in `with:`.

```
# <NN>: <MR title>
repo: <name> <local path>
branch: <type>/<ticket>-<short-name>
base: <branch>
after: <NN | none>
with: <NN, … | none>

## 1. <task: one commit>
<what changes, in spec terms; code areas>
- [ ] <spec scenario name | observable check when no scenario fits>
```

- `base:` an earlier MR's branch only when this MR needs its code (stacked); else that repo's default branch name: `git remote set-head origin -a`, then `origin/HEAD` minus `origin/`: ✓ `base: trunk` ✗ `base: origin/trunk`.
- `branch:` ticket from `status.md`: ✓ `feat/abc-77-login-lockout`.
- Each spec scenario is an AC of exactly one task. Each task carries its own tests: never a tests-only or code-only task.
- Another repo's path: `## Related repos` in loaded `CLAUDE.md`, else a sibling folder of that name; else ask.
