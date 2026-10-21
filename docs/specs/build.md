# Build

`build` turns what's decided (a plan, a bug's findings, or a small request with nothing in doubt) into tested, reviewed pull requests and lands them, with your go-ahead before each commit, push or post.

## Why

Testing first, honest self-review, true docs and walking a PR through CI and comments all take discipline. Each one skipped comes back as a bug, stale doc or stuck PR.

## What

It builds from `plan`'s folder (approved specs, a ticket per PR, tasks), `research`'s findings or your request, a task at a time.

## Behaviour

- A request or findings that fit one PR, with nothing in doubt, are built without questions. Anything else goes to `plan`.
- Each acceptance criterion gets a failing test, then the least code that passes. A bug's repro is the first test.
- `review` and its checker vet each change against its ticket, task and specs.
- After each task it shows what it did and waits for your go-ahead to commit.
- Changes you then ask for reshape only uncommitted tasks (a rename means later tasks use the new name).
- Changing a ticket's what, why or criteria, or a spec, goes back to `plan`, whether you ask then or in a review thread.
- It commits the plan's specs with the first task, each at its path in the repo, but never tickets or tasks.
- After the last task, it lists the PRs in merge order by ticket title and asks before opening them.
- When landing, it rebases, fixes CI and answers threads, then waits for your go-ahead to push and post, never merging.
- A CI test that passes locally goes to `research`. `build` fixes the PR's fault and reports anything else.
- A PR someone else wrote goes to `review`.
- Once every PR merges, it prunes their branches and offers to archive the plan.

## Decisions

- **`build` never asks what you mean**: Why: doubt means planning isn't finished.
- **A direct request is one PR's worth**: Why: splitting work into PRs is planning, however exact the request.
- **The plan's ticket file, not the tracker's**: Why: it's what `plan` checked and split into tasks. A filed copy can drift or not exist yet. A plan without tickets goes back to `plan`.
- **At a pause, changes reshape only later tasks, and a ticket or spec change needs replanning**: Why: committed work stays as reviewed, and tickets and specs are what you approved.
- **Docs a change makes untrue are fixed in its commit, unasked, never history or the plan's specs**: Why: whoever makes a change knows what it made untrue. A changelog records the past, and the plan's specs are what the code must match.
- **The plan's specs ship in its first commit**: Why: it's the first change relying on them.
- **A spec changed on the base goes back to `plan`**: Why: overwriting it would undo someone's change. Not telling this plan's own merged changes apart: rare, and costs one revision.
- **`build` stays in your worktree**: Why: switching the main checkout would change another session's branch.
- **A split carries the branch's code and tests, and never touches the branch**: Why: the work's done and tested, and the branch is the only full copy until every piece merges. Carried code that fails alone goes back to `plan`.
- **CI findings serve only their own PR, and an older flaky test is only reported**: Why: a test can fail on a later PR for a new reason, and fixing one mid-landing mixes unrelated work in.
