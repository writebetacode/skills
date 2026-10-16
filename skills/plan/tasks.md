Tasks from the plan's `specs/` alone; never `findings.md`, tickets, this conversation or `research/` (but upgrades, below). Per spec, only its change since its `spec:` line commit (`git show <commit>:docs/specs/<area>.md` in its repo; missing → new): new → every scenario; edited → each scenario added or changed in behaviour, each Design behaviour change no scenario covers (observable check), each removal Scope's Out names (AC: behaviour gone); slimmed, reworded or merged → none. Each is an AC of exactly one task; never a tests-only or code-only task.

`tasks/NN-<mr>.md`: terse. MR = one branch that works and ships alone; MRs merge in NN order. One repo per MR; work spanning repos → one MR per repo, each naming the others in `with:`.

```
# <NN>: <MR title>
repo: <name> <local path>
branch: <type>/<ticket>-<short-name>
base: <branch>
after: <NN | none>
with: <NN, … | none>
from: <branch | none>

## 1. <task: one commit>
<what changes, in spec terms; code areas>
- [ ] <spec scenario name | observable check when no scenario fits>
```

- `base:` an earlier MR's branch only when this MR needs its code (stacked); else that repo's default branch name, from `<this skill's base directory>/../../bin/default-branch.sh <repo path>`: ✓ `base: trunk`, never `origin/trunk`.
- `repo:` path: `<this skill's base directory>/../../bin/main-checkout.sh <path>`.
- `branch:` ticket from `status.md`: ✓ `feat/abc-77-login-lockout`.
- Each dependency research shows the change needs newer (an API, a bug it'd hit, a security fix, a deprecated version; never unrelated): its own task, first in the MR needing it; breaking changes reaching untouched code → its own MR first. Body: package, both versions, why, each breaking change with `path:line`. ACs: `- [ ] <package> <to>: suite passes (the bump is config: no new test)`, plus one tested AC per breaking change.
- Another repo's path: Related repos; else ask.
