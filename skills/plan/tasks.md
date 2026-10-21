`tasks/NN-<mr>.md`, beside its ticket: terse; the how. MR = one branch that works and ships alone. One repo per MR; spanning repos → one MR per repo, each naming the others in `with:`. How: `research/`, `findings.md`, the code, the user's choices; reuse what the repo has, the way it does things now.

```
# <NN>: <ticket title>

repo: <name> <local path>
branch: <type>/<ticket>-<short-name>
base: <branch>
after: <NN | none>
with: <NN, … | none>
from: <branch | none>

## 1. <task: one commit>

<how: components and where, interfaces, data, errors, tests; why behind non-obvious choices>

- [ ] <one of its ticket's ACs, verbatim>
```

- Each of the ticket's ACs under exactly one task; every task has one. Never a tests-only or code-only task.
- `base:` an earlier MR's branch only when this MR needs its code (stacked); else that repo's default branch name, from `<this skill's base directory>/../../bin/default-branch.sh <repo path>`: ✓ `base: trunk`, never `origin/trunk`.
- `repo:` path: `<this skill's base directory>/../../bin/main-checkout.sh <path>`.
- `branch:` ticket: the MR's on `status.md`, else its `ticket:`: ✓ `feat/abc-77-login-lockout`; none → `<type>/<short-name>`.
- Each dependency research shows the change needs newer (an API, a bug it'd hit, a security fix, a deprecated version; never unrelated): its own task, first in the MR needing it, with [tickets.md](tickets.md)'s bump ACs; breaking changes reaching untouched code → its own MR and ticket first. Body: package, both versions, why, each breaking change with `path:line`.
- Another repo's path: Related repos; else ask.
