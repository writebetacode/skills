# Plan

`plan` turns a request into specs and tasks you've agreed on before any code exists, so building never has to guess. It keeps one living spec per domain area in a flat `docs/specs/`, because a spec written per change goes stale as soon as the next change lands. It also proposes the dependency upgrades a change needs, splits a branch that grew too big to review into tasks that reuse its work, and investigates failures, including CI tests `build` can't reproduce.

## Context

`plan` agrees on each request with you through `same-page`, one question at a time, then researches it quietly: how things work here, patterns to follow, versions in use, other repos touched. It keeps its working files in a plan folder under the repo's `.ai/plan/`, which lives in the main checkout and is shared by every worktree (bare repos aside). A spec checker agent reads each draft spec in a fresh context and reports gaps before you see it; `plan` fixes what it agrees with and raises the rest as open questions in the walk, where you approve or change the spec.

`review` already lets you drop items from a numbered file: you move one under a `## Withdrawn` heading or say "withdraw" and its number.

For a bug, `plan` investigates: it reproduces the failure, walks the failing path citing each line it read, proves the cause in a throwaway worktree, has a checker agent challenge it, and writes findings with ways to fix it and a recommendation. It asks you only what nothing it can reach answers.

`build` builds the tasks test-first, one commit each, reading only the plan's specs and tasks (an approved upgrade travels in its task), plus the branch a split carries code from.

## Scope

In: where specs live, how they're named, grow and get checked, and how tasks come from them; requests that are only upgrades; the dependency-upgrade step; splitting a branch into tasks; investigating a test `build` hands over; the spec rules file; the README's `plan` section; marking "Living specs in `plan`", "Split a branch in `plan`" and "Track down flaky tests" Done in `docs/proposed-improvements.md`.
Out: how `build` writes specs and carries a split branch's code (the build spec); how the spec checker works (the spec-checker spec); merging or deleting a split branch; upgrading dependencies the change doesn't touch.

## Behaviour

```gherkin
Scenario: A change to a defined area updates its spec
  Given docs/specs/daily.md defines daily
  When you plan a new source for daily
  Then the plan edits daily's spec and adds no new one

Scenario: A new area gets a spec named for it
  Given no spec defines ticket
  When you plan ticket's search before filing
  Then the plan's new spec is ticket.md, defining only that search

Scenario: A spec grows as its area changes
  Given docs/specs/ticket.md defines ticket's search before filing
  When you later plan a change to how ticket writes titles
  Then the plan adds titles to ticket.md

Scenario: Specs never sit in sub-folders
  Given an epic named launch with a refunds feature in the payments area
  When the feature's spec is approved
  Then the plan's status lists docs/specs/payments.md
  And the epic's own spec stays in its plan folder

Scenario: One plan, several specs
  Given a plan that adds a review spec and edits daily's
  When you approve it
  Then the plan's status lists both paths
  And the task writer and build read both

Scenario: Tasks cover only what changed
  Given a plan edits one of daily.md's scenarios and adds another
  When plan writes tasks
  Then those two scenarios are the acceptance criteria, and daily's unchanged scenarios aren't

Scenario: A removed scenario still gets a task
  Given a plan removes one of daily.md's scenarios
  When plan writes tasks
  Then a task checks that the behaviour it described is gone

Scenario: A request that's only an upgrade
  When daily suggests /wbc:plan to fix a lodash vulnerability in shop, web and api
  Then plan writes upgrades.md alone, with no spec, and tasks once you approve it

Scenario: Propose upgrades that serve the change
  Given an approved spec for refunds, the repo on stripe 14, and stripe 16 adding the refund API the spec needs
  And eslint is two majors behind
  When plan reaches the upgrade step
  Then upgrades.md proposes stripe 14 to 16, saying why the change needs it, the breaking changes that hit this repo with where, and which MR it ships in
  And eslint isn't mentioned

Scenario: Nothing worth upgrading
  Given every dependency the change touches is current or an upgrade wouldn't help it
  When plan reaches the upgrade step
  Then no upgrades.md is written and the plan's status says upgrades: none

Scenario Outline: Withdraw an upgrade
  Given upgrades.md proposes upgrades 1 and 2
  When you <action>
  Then upgrade 2 sits under Withdrawn and never becomes a task

  Examples:
    | action                         |
    | say "withdraw 2"               |
    | move upgrade 2 under Withdrawn |

Scenario: Withdraw an upgrade the design needs
  Given the refunds design needs stripe 16's refund API
  When you withdraw the stripe upgrade
  Then plan says the specs can't be built as written and revises them with you

Scenario: Lock in on approval
  Given you've withdrawn what you don't want
  When you approve the upgrades
  Then the plan's status records upgrades: approved with the date
  And tasks are written only after that

Scenario: Upgrades ship inside the change where they can
  Given an approved upgrade the first MR's code depends on
  When plan writes tasks
  Then the upgrade is the first task of that MR

Scenario: An upgrade too big to ride along
  Given an approved upgrade whose breaking changes reach code the change doesn't touch
  When plan writes tasks
  Then the upgrade gets its own MR, merged before the others

Scenario: Split a branch that grew too big
  Given feat/big-cart mixes a refactor, a feature and a config change
  When you ask plan to split feat/big-cart
  Then it writes the specs for what the branch does and tasks for three MRs: the refactor, the feature stacked on it, and the config change
  And each task names the files or hunks it carries from feat/big-cart
  And the refactor and config tasks are checked by the full suite

Scenario: A split branch's own version bump becomes an upgrade
  Given feat/big-cart bumps stripe from 14 to 16
  When you ask plan to split it
  Then upgrades.md proposes stripe 14 to 16 like any other upgrade, and no task carries the bump

Scenario: Investigate a test that fails only sometimes
  Given build hands over a checkout test that failed in CI on PR 45 and passed locally
  When plan investigates it
  Then there's no same-page round
  And it runs the test alone up to 50 times at PR 45's head, until it fails
  And the findings say what makes it fail only sometimes, and go back to build

Scenario: The findings say whether the PR caused it
  Given the handed-over test failed on the 7th run at PR 45's head
  When plan reruns it the same way at PR 45's base
  Then the findings say whether it fails there too

Scenario: A test that fails only in CI is a bug, not a flake
  Given build hands over a test that failed in CI
  And it passes 50 runs alone and 5 runs of the whole suite in CI's order
  When plan investigates it
  Then it looks for what differs between CI and your machine, as an ordinary bug
```

## Design

**Specs.** `docs/specs/` holds one spec per domain area, with no sub-folders. A domain area is a skill, an agent or an area of an app (`review`, `spec-checker`, `payments`), and its spec is named for it, never for the plan, epic or change that produced it. A spec is the living definition of its area: every change to the area updates the spec in the same change, rewriting the parts that change so it reads as today's truth, with each overturned Decision replaced by the new one and why.

After `same-page`, `plan` works out which areas the request touches and writes each touched spec in the plan folder as `specs/<name>.md`: an area with a spec starts from a copy of it at the base branch's fetched tip; an area without one starts a new spec holding only what this change defines, which grows as later changes touch the rest of the area. Each spec is checked by the spec checker and walked with you. On approval the plan's status reads `spec: approved <date>: <repo>@<commit> <path>, …`, listing every `docs/specs/` path the plan adds or edits, none of them primary, each with the repo it ships in and that base commit, which the copies came from. When `build` hands a plan back because a spec changed on the base, `plan` starts that spec again from the base's current version, merges its own changes in (a new spec whose path now exists becomes an edit of it), checks and walks the changes, and records the new base commit; any revision does the same for each spec it touches. A plan with no spec, being only upgrades, reads `spec: none`. The specs stay in the plan folder until `build` commits them. A spec that defines no area (an epic's, listing its features in build order, or a research request's answer) is `spec.md` at its plan or epic folder's root, off the status line and never committed; each feature's specs follow the rules above.

Tasks come from what the specs change, against that base commit: for a new spec, every scenario; for an edited one, each scenario added or changed, each removed scenario (checking the behaviour is gone), and each change to its Design with no scenario (an observable check). The task writer and `build` read every spec on the status line.

The spec rules file changes to match: its subject is `specs/<name>.md`, one per domain area; the opening is "2–3 sentences: what it does, for whom, why"; Context is "what it builds on: the code, repos and constraints involved". A bug's proven cause goes into the Decision it shapes, as the why.

**Related repos.** `plan` reads them, and its investigations `## Debug tools`, from the `CLAUDE.md` and `CLAUDE.local.md` of the repo's main checkout (found by the shared main-checkout script), wherever it runs, resolving each path from that checkout.

**Upgrades.** After the specs are approved and before tasks, `plan` takes each dependency that the new or changed parts of its specs touch, at the version in use on the base branch. For each, it finds the latest stable version (the registry's CLI, else the release notes) and reads the changes between the two. It proposes an upgrade only when it serves the change: an API it needs, a bug it would hit, a security fix, or a version so old the new code would build on something deprecated. It writes them to `upgrades.md` in the plan folder, one numbered upgrade per package per repo, numbered like a review: package and both versions, why, the breaking changes that touch this repo with where, and where it ships (inside a named MR, or its own MR before the others). No upgrades → no file and `upgrades: none`. It walks the list in a few lines; you withdraw as in `review`; other changes are edited in and walked again. Withdrawing one the design needs → `plan` says the specs can't be built as written and revises them with you. Explicit approval → `upgrades: approved <date>`; while walking, `upgrades: draft`. The upgrades never appear in a spec. A request that's only an upgrade (a security fix `daily` found, say) gets `upgrades.md` alone, with no spec, walked the same way, then tasks.

Each approved upgrade becomes the first task of the MR it ships in, or its own MR numbered before the others. Its checks: the suite passes on the new version, and each listed breaking change is handled, each with a test. A revision that touches new dependencies runs this step again for those only, keeping earlier upgrades and their numbers. A plan paused at `upgrades: draft` resumes at that walk, and `build` sends it back to `plan`.

**Splitting a branch.** Asked to split a branch, `plan` researches the branch's changes against its base, writes or edits the specs for what the branch does, and walks them as usual. Versions in use are the base's; a version bump on the branch becomes a proposed upgrade, its task redoing the manifest and lockfile change and carrying the branch's hunks that adapt code to it. The task writer reads the branch's diff as well as the specs, and each task file gains a `from:` line naming the branch (`none` otherwise). Each task lists what it carries: whole files where a file belongs to one task, else its hunks, by path and what they change. A task that changes no behaviour (a refactor or config change) has one acceptance criterion, "suite passes (no behaviour change: no new test)", which is how `build` knows the suite is its check; every other task carries its own tests.

**A test handed over by `build`.** `build` hands over the failing test, the CI job and its log, and the PR's branch and head commit. The problem is exact, so there's no `same-page` round. The investigation runs in a throwaway worktree at that head commit: the test alone up to 50 times, stopping at the first failure; if it never fails, the whole suite in CI's order up to 5 times. It fails sometimes → flaky: prove the cause as usual. It never fails → investigate what differs between CI and your machine (versions, settings, services, data) as an ordinary bug. Still no repro → the findings say so, with confidence at most medium. A failure it reproduces is rerun the same way at the PR's base, so the findings say whether the PR's change causes it. The findings go back to `build`, which decides what happens to the fix.

The README's `plan` section describes living specs, splitting a branch and investigating a test `build` hands over, and the three rows above move to Done in `docs/proposed-improvements.md`. The upgrade-path spec becomes part of this one.

Testing: the repo's check script and markdownlint; planning a change to an existing spec and to an area without one; a plan with an outdated dependency in a scratch repo; splitting a sample branch with a version bump; investigating a planted flaky test.

## Decisions

- **One living spec per domain area, in a flat folder**: Why: a spec is where its area is defined, so it must change whenever the area does, and one place per area is easy to find. Not a spec per change: it goes stale the moment the next change lands. Not sub-folders per epic or plan: they name history, not areas.
- **Named for the area, not the feature**: Why: a spec grows as more of its area changes. Not the feature: the name would stop fitting. An agent is its own area: it's a separate component with its own rules.
- **Specs stay in the plan folder until `build` commits them**: Why: the plan folder is shared by every checkout of the repo (bare repos aside), while `docs/specs/` belongs to whichever branch is checked out, and a plan never built leaves nothing behind. Not moving them into `docs/specs/` on approval: a build in another worktree wouldn't see them.
- **An epic's own spec stays in the plan folder**: Why: it orders features, which is planning, and defines no area. Not a spec in `docs/specs/`.
- **Tasks cover only what changed**: Why: unchanged scenarios already hold, and rebuilding them is waste. Not every scenario of an edited spec.
- **Copies come from the base branch's tip**: Why: that's what the change will merge into, and `build`'s check for later edits needs one fixed point. Not whatever the checkout happens to have.
- **An upgrade-only request needs no spec**: Why: it changes no area's behaviour. Not an empty spec.
- **Upgrades after approval, before tasks**: Why: the design has to be settled to know which dependencies it touches, and tasks need to know what's upgraded. Not during research: the design isn't agreed yet.
- **Upgrades in `upgrades.md`, never a spec**: Why: a spec says what an area does, whichever versions you pick; upgrades are a delivery choice. Not a spec section.
- **`review`'s withdraw mechanic for upgrades**: Why: you already know it, and editing a file is quicker than answering questions about each upgrade. Not one question per upgrade.
- **Only dependencies the change touches, and only when it helps**: Why: unrelated upgrades bloat the MRs and their review. Not a general outdated-dependency report.
- **Upgrades inside the change's MRs where possible, else just before them**: Why: they ship with what needs them; one that reaches unrelated code is safer reviewed alone. Not always a separate MR.
- **A version bump is config: the suite is its check**: Why: the bump itself has no behaviour to test; what it breaks does, and each breaking change gets a test. Not a test for the bump.
- **`build` sends an unapproved upgrade list back to `plan`**: Why: a plan paused at the walk has no tasks, and `build` would otherwise close it as finished. Not leaving `build`'s gate unaware of the pause.
- **Splitting belongs to `plan`**: Why: deciding the pieces is planning. Not `pr`: it handles one PR on one branch. Not `build`: it builds only what's decided.
- **A split branch's version bumps become upgrades**: Why: an upgrade gets the same scrutiny wherever it came from. Not a hunk a task carries.
- **A no-behaviour task is marked by its one suite-check criterion**: Why: `build` needs to know when no failing test is possible, and the task format already holds criteria. Not a new field.
- **The investigation, not `build`, decides a test is flaky**: Why: telling flaky from CI-only takes reruns and evidence. Not a rule in `build`: it would guess.
- **50 runs alone, then 5 of the suite**: Why: 50 catches a 1-in-20 flake with high odds and is quick for one test; a few suite runs catch flakes that need other tests first. Not unlimited: it has to stop.
- **No `same-page` for a test `build` hands over**: Why: the failing test, the job and its log already say what's wrong. Not a round with you: there's nothing to agree on.
- **Findings from a handed-over test go back to `build`**: Why: `build` was landing the PR and carries on with the fix. Not a reply to you: it would stall the landing.
- **A reproduced flake is also run at the base**: Why: where the fix goes depends on whether the PR caused it. Not guessing from the diff.
