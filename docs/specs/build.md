# Build

`build` builds what's already decided (a plan's tasks, findings, or a small request with nothing in doubt) test-first into reviewed PRs, then lands them. Anything in doubt goes to `plan`, because settling what to build is planning. Whatever its change makes untrue in a spec, README or other doc gets fixed in the same commit, without asking.

## Context

For each task, `build` writes a test per acceptance criterion that fails for the reason the criterion names, then the least code that passes. A fresh agent reviews the change through `review`, the review checker confirms each finding, and `build` waits for your go before committing. Landing rebases the PRs, fixes failing CI from the job logs and drafts replies to review comments, again waiting for your go before it pushes or posts.

`plan` keeps a plan's specs in its plan folder, shared by every checkout (bare repos aside), and records on the plan's status each spec's repo, path and the commit its copy came from. A split's tasks name their branch in `from:` and list what they carry; a task that changes no behaviour has one criterion, a suite check. `research` writes findings with a recommended fix.

## Scope

In: which requests `build` takes; committing a plan's specs; split tasks; CI failures that pass locally; PRs you didn't write; fixing the docs a change makes untrue; closing a plan; the README's `build` section.
Out: how `plan` splits a branch and how `research` investigates (their specs); building an older flaky test's fix while landing another PR; epics; plans waiting on an `upgrades: draft` walk, which `plan` no longer writes.

## Behaviour

```gherkin
Scenario: An exact request is built directly
  When you ask build to fix the typo on line 3 of the README
  Then build fixes it without asking you anything first

Scenario Outline: Anything in doubt goes to plan
  When you ask build to <request>
  Then build hands the request to plan and builds nothing

  Examples:
    | request                                  |
    | make checkout faster                     |
    | rename the Cart class across four repos  |

Scenario: Docs a change makes untrue are fixed with it
  Given the README and docs/specs/checkout.md both describe the --express flag
  When you ask build to rename --express to --fast
  Then the same commit updates the README and that spec, without asking you
  And the changelog's older entries still say --express

Scenario: A plan's specs ship from the checkout that builds it
  Given a plan made in ~/code/shop, with an approved new spec and an edited one
  When you build its first task in a worktree of shop
  Then both specs are written into the worktree's docs/specs/ before that task's review, and its commit includes them

Scenario: A spec that changed since planning goes back to plan
  Given a plan edited docs/specs/daily.md
  And someone changed daily.md on the base branch after the plan was made
  When build starts the plan's next task
  Then it hands the plan back to plan to revise and builds nothing

Scenario: A split task carries the branch's code and tests
  Given plan split feat/big-cart
  When build builds the feature's task
  Then the task's tests come from feat/big-cart and fail before its code is added, and its code makes them pass
  And a carried test that passes before the code gets a failing test of build's own beside it
  And feat/big-cart itself is left unchanged

Scenario: Carried code that doesn't work alone goes back to plan
  Given the feature task's code from feat/big-cart needs a hunk the split put in a later task
  When build runs the task's tests
  Then it hands the plan back to plan to revise the split and commits nothing

Scenario: A CI failure this PR causes is fixed on the PR
  Given CI fails a checkout test on PR 45 that passes when build runs it locally
  When build lands PR 45
  Then it hands the failure to research without asking you
  And once the findings blame PR 45's change, it fixes it on PR 45's branch and carries on landing

Scenario: An older CI failure is reported
  Given the findings show the test fails the same way on PR 45's base
  When build carries on landing PR 45
  Then it reports PR 45's CI as red from that test, with the findings' path, and builds no other fix

Scenario: A PR you didn't write goes to review
  Given someone else wrote PR 50
  When you ask build to land PR 50
  Then it hands PR 50 to review and changes nothing

Scenario: Closing a plan cleans up its branches
  Given every MR of a plan has merged
  When build closes the plan
  Then it runs the shared cleanup on each MR branch and offers to archive the plan folder
```

## Design

**Requests.** `build` never runs `same-page` on a request. A request becomes one task only when it fits one PR and nothing about it is in doubt (what changes, where, what done looks like), with acceptance criteria written from it; anything else goes to `plan`. Findings, read from `.ai/research/<name>/findings.md`, follow the same rule: their recommended fix becomes the task, its repro the first criterion. A criterion reading `suite passes (… no new test)` is checked by the full suite, split or not; one reading `<package> <to>: suite passes (the bump is config: no new test)` marks a version-bump task, which redoes the bump with the package manager, its breaking-change criteria built test-first. An upgrade you ask for, such as one of `daily`'s security items, is a request like any other; one spanning several PRs goes to `plan`, which plans it with no spec, and `build` builds that plan's tasks (`spec: none`).

**A plan's specs.** `build` reads every spec on the plan's status line from the plan folder. Before each task's tests, it writes into the checkout's `docs/specs/` each spec for this repo whose plan copy differs from the checkout's. First it fetches: when the base branch's version matches neither the status line commit's version nor the plan's copy, someone else changed it, so the plan goes back to `plan` to revise and `build` builds nothing. A copy `build` committed itself for an earlier revision of the plan also trips this check; `plan`'s revise then starts from it.

**Docs.** Once a change passes its tests, `build` searches the repo for every name, term and behaviour it touched and fixes each spec, README, doc, docstring and comment that's no longer true, in the same commit. History stays as it was (changelogs, migrations), and so do the specs on a plan's status line: a change that contradicts one is fixed to match it, or goes back to `plan`.

**Review.** Each change gets a fresh agent that invokes `review` for a local review against the specs, the task, the findings or the request, told which later tasks and MRs of the plan are still to come. The review checker then confirms its findings. `build` fixes each survivor and reviews again, at most three rounds.

**Worktrees.** A task's `repo:` is the repo's main checkout; run in a worktree of it, `build` works there.

**Split tasks.** `build` carries what a task lists from the branch's diff against the default branch, from where they diverge, applied three-way so the base's later changes stay. A task whose one criterion is the suite check takes its code. A version-bump task redoes the bump, then carries its listed hunks. Any other task takes its tests first and sees them fail, then its code and sees them pass. Carried code that fails its tests or the suite is put back, and the plan goes back to `plan`. `build` never changes, rebases or deletes the `from:` branch.

**CI failures that pass locally** go to `research` without asking, with the test, the job and its log, and the PR's branch, head and base commits. PR causes it → `build` fixes it on the PR's branch, test-first. Anything else (it fails the same way at the base, a CI-only difference, no cause found) → `build` lists it as what's left, with the findings' path. A test that already has a findings folder under `.ai/research/`, named from the test, isn't handed over again.

**PRs you didn't write.** `build` compares the PR's author with your login; someone else's PR goes to `review`.

**Closing a plan.** Once every MR has merged, `build` runs the shared `prune-merged.sh` (the pr spec) on the MR branches, then offers to move the plan folder into `completed/`.

The README's `build` section says unclear work goes to `plan` first, a CI test that passes locally goes to `research` and an older one is reported with its findings, and `build` fixes the docs its changes make untrue.

Testing: the repo's check script and markdownlint; building a small exact request and a rename the README and a spec describe; building tasks from a sample split branch; landing a PR with a planted flaky test.

## Decisions

- **`build` never asks what you mean**: Why: its job is to build what's decided; doubt means planning isn't finished. Not a `same-page` round inside `build`.
- **One PR's worth for a direct request**: Why: splitting work into PRs is planning, however exact the request. Not one task of any size.
- **`build` fixes stale docs itself, but never history or the plan's own specs**: Why: whoever makes a change knows best what it made untrue, while a changelog records what was true then and a plan's specs are what the code must match. Not flagging docs for you to fix by hand.
- **The plan's specs ship with its first commit**: Why: specs ship with the first change that relies on them, from whichever checkout builds it. Not a commit of their own first.
- **A spec changed on the base goes back to `plan`**: Why: overwriting it would silently undo someone's change. Not merging the two by hand in `build`. Not tracking which base versions `build` committed itself: a revise after a merged MR rarely happens, and the extra hand-back costs one revise.
- **`build` stays in your worktree**: Why: you chose to work there, and switching the main checkout would change the branch under another session.
- **A split task carries the existing code and tests**: Why: the work is done and tested; a carried test that already passes gets a failing one beside it so the task still proves its change. Not rebuilding from scratch.
- **The `from:` branch is never touched**: Why: it's the only complete copy until every piece merges, and you decide when it's safe to delete. Not cleaning it up with the merged MR branches.
- **An older flaky test is only reported**: Why: its fix is separate work you start from the findings, and building it mid-landing mixes unrelated work into the run. Not opening a fix PR of its own unasked.
- **PRs you didn't write go to `review`**: Why: you can't push to someone else's PR as yours. Not landing them.
