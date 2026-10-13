No `tasks/`, or every MR `merged` → Close. Every MR `open` or `merged` → [land.md](land.md).

## MRs

1. Reply: the feature's MRs in merge order: NN, repo, branch → base, task count, which ship together (`with:`). Ask to open them.
2. Approved → in NN order: base as in SKILL.md Task step 1; it changed since the branch was cut → rebase per land.md step 2. `pr` skill: open, with that base and the merge order of all the feature's MRs. All open → `pr` on each earlier one to add the later URLs. `status.md`: `open <url>`. Then land.md.
3. Epic with features left → this feature `done`; start the next unasked.

## Close

Fetch; on the default branch, each MR's local `branch:`: `git merge-tree --write-tree origin/<default> <branch>` prints `git rev-parse origin/<default>^{tree}` → `git branch -D` (squash merges defeat `-d`); else, or any error, keep it, say why. Then ask "Done? I'll archive `<folder>`." Yes → move it to `.ai/plan/completed/<YYYY-MM-DD>-<name>/` (an epic moves whole; target exists → stop). Never merge.
