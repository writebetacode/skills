Splitting a branch (asked here, or sent by `build` or `pr`): the request is that branch against its base; `status.md` gets `from: <branch>`. Never change, rebase or delete the branch.

- Step 3 also reads its diff, `git diff origin/<base>...<branch>`; versions in use are the base's.
- Step 4 writes or edits the specs for what the branch does.
- Each version bump on the branch → its own task first (tasks.md's upgrade rule), even if no spec needs it: it redoes the manifest and lockfile change, naming their hunks as redone, then carries the hunks that adapt code to it.
- Step 6 reads the branch's diff as well as the specs; each task file's `from:` names the branch, and its `branch:` differs from it. Each task lists what it carries: whole files where a file belongs to one task (a move: `old → new`), else its hunks, by path and what they change. Each hunk of the diff goes to exactly one task, or step 7's reply names it as left out. A task that changes no behaviour (a refactor, a config change) has one AC: `suite passes (no behaviour change: no new test)`; every other task carries its own tests.
