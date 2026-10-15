Tasks from the spec and approved `upgrades.md` alone, never its `## Withdrawn`: never open `research/`, `findings.md` or tickets; ignore this conversation.

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

- `base:` an earlier MR's branch only when this MR needs its code (stacked); else that repo's default branch name, from `<this skill's base directory>/../branch/default-branch.sh <repo path>`: ✓ `base: trunk` ✗ `base: origin/trunk`.
- `repo:` path: the main checkout, from `<this skill's base directory>/main-checkout.sh <path>`.
- `branch:` ticket from `status.md`: ✓ `feat/abc-77-login-lockout`.
- Each spec scenario is an AC of exactly one task. Each task carries its own tests: never a tests-only or code-only task.
- Each approved upgrade: its own task, first in the MR its `Ships:` names, else its own MR numbered before them. Body: package, both versions, why, each breaking change with `path:line`. ACs: `- [ ] <package> <to>: suite passes (the bump is config: no new test)`, plus one per breaking change handled, each with a test.
- Another repo's path: `## Related repos` in loaded `CLAUDE.md`/`CLAUDE.local.md`, else a sibling folder of that name; else ask.
