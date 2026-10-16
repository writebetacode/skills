A `from:` task (a split): carry what it lists from the branch's diff, so the base's later changes stay: `git diff --binary origin/<default>...<branch> -- <paths> | git apply -3` (`<default>`: `<this skill's base directory>/../../bin/default-branch.sh`); hunks: only those. Never change, rebase or delete that branch.

- A `suite passes (… no new test)` AC → carry what it needs; the full suite is its check. A version bump: redo it with the package manager first.
- Else carried tests first: see them fail; then the code: see them pass. One passing early → also a failing test of your own.
- Carried code fails its tests or the suite → `git restore --staged --worktree -- <paths>`; hand the plan back to `plan` (revise); commit nothing.
