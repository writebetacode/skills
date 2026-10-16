# Build

`build` builds what's already decided (a plan's specs and tasks, findings, or a small request with nothing in doubt) and works out the best way to do it. Anything in doubt goes to `plan`, because settling what to build is planning, and building on a guess wastes your review. It also ships a plan's specs from whichever checkout builds it, reuses a split branch's tested work instead of rewriting it, and hands CI failures it can't reproduce, and PRs you didn't write, to the skill that should handle them.

## Context

`build` works one task at a time, test-first: for each acceptance criterion a test that fails for the reason the criterion names, then the least code that passes. A fresh agent reviews each change and a checker agent confirms each finding; `build` then waits for your go before committing. It then lands the PRs: it rebases them, fixes failing CI from the job logs, and drafts replies to review comments, waiting for your go again before it pushes or posts. A request that won't fit one PR goes to `plan`.

`plan` keeps a plan's specs in its plan folder, shared by every checkout of the repo (bare repos aside), and records on the plan's status every spec path it adds or edits and the commit the plan was made on. When `plan` splits a branch, each task names the branch it carries from in a `from:` line and lists the files or hunks it carries; a task that changes no behaviour has one criterion, a suite check. `plan` investigates failures and writes findings with a recommended fix. `review` keeps reviews of PRs you reviewed in local files. These parts of `plan` ship together with this spec.

## Scope

In: which requests `build` takes and which go to `plan`; committing a plan's specs; building tasks from a split branch; CI failures that pass locally; PRs you didn't write; the README's `build` section; marking "`build` hands doubt to `plan`" Done in `docs/proposed-improvements.md`.
Out: how `plan` splits a branch or investigates a test (the plan spec).

## Behaviour

```gherkin
Scenario: An exact request is built directly
  When you ask build to fix the typo on line 3 of the README
  Then build fixes it without asking you anything first

Scenario: An unclear request goes to plan
  When you ask build to make checkout faster
  Then build hands the request to plan and builds nothing

Scenario: An exact request too big for one PR goes to plan
  When you ask build to rename the Cart class everywhere, across four repos
  Then build hands the request to plan and builds nothing

Scenario: A request to split a branch goes to plan
  When you ask build to split feat/big-cart
  Then build hands the request to plan and builds nothing

Scenario: A plan's specs ship from the checkout that builds it
  Given a plan made in ~/code/shop, with an approved new spec and an edited one
  When you build its first task in a worktree of shop
  Then both specs are written into the worktree's docs/specs/ before that task's review, and its commit includes them

Scenario: A spec that changed since planning goes back to plan
  Given a plan edited docs/specs/daily.md
  And someone changed daily.md on the base branch after the plan was made
  When build starts the plan's first task
  Then it hands the plan back to plan to revise and builds nothing

Scenario: Build works in your worktree
  Given a plan whose task names ~/code/shop as its repo
  When you run build in a worktree of shop
  Then it builds and commits in that worktree, leaving the main checkout's branch alone

Scenario: Closing a plan from a worktree
  Given every MR of a plan has merged and you're in a worktree of shop
  When build closes the plan
  Then it deletes each merged MR branch without switching branches
  And it keeps a branch still checked out in some worktree, saying why

Scenario: A plan that's only upgrades
  Given a plan whose status reads spec: none and upgrades: approved, with tasks
  When you run build
  Then it builds the tasks without sending the plan back to plan

Scenario: A behaviour task carries the branch's code and tests
  Given plan split feat/big-cart and you approved it
  When build builds the feature's task
  Then the task's tests come from feat/big-cart and fail before its code is added
  And the task's code comes from feat/big-cart and makes them pass
  And a new test is written only for an acceptance criterion the branch has no test for

Scenario: A carried test that already passes gets a real one
  Given a test carried from feat/big-cart passes before the task's code is added
  When build builds that task
  Then it writes its own failing test for that criterion, keeping the carried test too

Scenario: Carried code that doesn't work alone goes back to plan
  Given the feature task's code from feat/big-cart needs a hunk the split put in a later task
  When build runs the task's tests
  Then it hands the plan back to plan to revise the split and commits nothing

Scenario: A refactor task is checked by the suite
  Given plan split feat/big-cart and you approved it
  When build builds the refactor's task
  Then its code comes from feat/big-cart and the full suite passes

Scenario: The split branch is left alone
  Given build has built every task split from feat/big-cart
  Then feat/big-cart itself is unchanged and still exists

Scenario: A CI failure this PR causes is fixed on the PR
  Given CI fails a checkout test on PR 45 that passes when build runs it locally
  When build lands PR 45
  Then it hands the failure to plan's investigation without asking you
  And once the findings blame PR 45's change, it fixes it on PR 45's branch and carries on landing

Scenario: An older flaky test gets its own fix
  Given the findings show the flaky test fails the same way on the base branch
  When build carries on landing PR 45
  Then it reports PR 45's CI as red from that test and builds the fix on its own branch from the findings

Scenario: A flake with no cause found is reported
  Given the investigation couldn't make the test fail
  When build carries on landing PR 45
  Then it lists the test as what's left, with the findings' path

Scenario: A PR you didn't write goes to review
  Given you reviewed PR 50, which someone else wrote
  When you ask Claude to address the comments on PR 50
  Then review re-reviews it and drafts answers in its review file, instead of build
```

## Design

**Requests.** `build` never runs `same-page` on a request; its other questions (which of several plans, a host it can't tell) are asked the repo's usual way. A request becomes one task only when it fits one PR and nothing about it is in doubt: what changes, where, and what done looks like. `build` writes that task's acceptance criteria from the request. Anything else, a request to split a branch included, goes to `plan`, and `build` stops.

**A plan's specs.** `build` reads every spec on the plan's status line from the plan folder; the line names each spec's repo and the commit of that repo the plan was made on. Starting each task, before its tests, `build` writes into that checkout's `docs/specs/` every spec for this repo whose plan copy differs from the checkout's version, so its reviews check the code against them and the task's commit includes them; a spec `plan` revised mid-build ships the same way. Before writing, it checks nobody else changed the file on the base branch: an edited spec whose fetched base version differs from the one at the status line's commit, or a new spec whose path now exists on the base, goes back to `plan` to revise first, and `build` builds nothing until then. Copies `build` committed itself never count as someone else's change. A plan whose status reads `spec: none` (only upgrades) has no specs to write and is built from its tasks once its upgrades are approved.

**Worktrees.** A task file's `repo:` is the repo's main checkout; when you run `build` in a worktree of that repo, it works there instead. Closing a plan from a worktree compares each MR's branch with `origin/<default>` without switching branches, and keeps any branch still checked out in a worktree, saying why.

**Split tasks.** On a task with a `from:` branch, `build` reads that branch as well as the specs and task. A task whose one criterion is the suite check takes its code from the branch, and the full suite passing is its check. Any other task takes its tests from the branch first and sees them fail, then takes its code and sees them pass. A carried test that passes before the code is added doesn't test this task, so `build` writes a failing test of its own for that criterion and keeps the carried one. A criterion with no test on the branch gets one written test-first. Carried code that doesn't pass its tests or the suite goes back to `plan` to revise the split. `build` never changes or deletes the `from:` branch.

**CI failures that pass locally.** In the land step, a failing CI test that passes when `build` runs it locally the way the job does goes to `plan`'s investigation without asking you, with the test, the job and its log, and the PR's branch and head commit. The findings say whether the PR's change causes it, and `build` carries on:

- The PR's change causes it → fix it on the PR's branch, test-first, and carry on landing.
- It fails the same way without the PR's change → finish this land round, reporting the PR's CI as red from it; then build the fix on its own branch, named from the findings, and open it once you say go. The PR lands once that fix merges and it's rebased.
- No cause found → list it as what's left, with the findings' path.

Either fix becomes one task only when it fits one PR with nothing left to decide; otherwise `build` hands the findings to `plan` to plan the fix with you. A test that already has findings isn't handed over again on later rounds. Infra failures and missing logs are still only reported.

**PRs you didn't write.** `build` compares the PR's author with your login. A PR someone else wrote goes to `review`, and `build` stops.

The README's `build` section says unclear work goes to `plan` first, and the row above moves to Done.

Testing: the repo's check script and markdownlint; building a small exact request; building tasks from a sample split branch, including a carried test that already passes; landing a PR with a planted flaky test; landing a PR someone else wrote.

## Decisions

- **`build` never asks what you mean**: Why: its job is to build what's decided; doubt means planning isn't finished. Not a `same-page` round inside `build`.
- **Still one PR's worth for a direct request**: Why: splitting work into PRs is planning, however exact the request. Not one task of any size.
- **`build` commits the plan's specs with its first commit**: Why: specs ship with the first change that relies on them, from whichever checkout builds it. Not committing them on their own first.
- **A changed spec goes back to `plan`**: Why: overwriting it would silently undo someone's change. Not merging the two by hand in `build`.
- **`build` stays in your worktree**: Why: you chose to work there. Not switching to the main checkout: it would change the branch out from under another session.
- **A split task carries the existing code and tests**: Why: the work is done and tested. Not rebuilding from scratch: it throws that work away.
- **A carried test that already passes gets a failing test beside it**: Why: test-first needs a test that proves the task's change. Not trusting the carried test alone.
- **The `from:` branch is never touched**: Why: it's the only complete copy until every piece merges. Not deleting it after: you decide when it's safe.
- **A flaky fix goes where its cause is**: Why: a flake this PR introduced must be fixed before it merges; an older one deserves its own PR. Not always on the PR: it would mix unrelated work.
- **PRs you didn't write go to `review`**: Why: your part there is answers in your review file, not code. Not landing them: you can't push to someone else's PR as yours.
