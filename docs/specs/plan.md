# Plan

`plan` turns a request into specs and tasks you've agreed on before any code exists, so `build` never has to guess. It keeps one living spec per domain area in a flat `docs/specs/`, and it can split a branch that grew too big to review into tasks that reuse its work.

## Context

`plan` agrees on each request with you through `same-page`, one question at a time, then gathers what the specs and tasks need through `research`, saving each report in its plan folder. Plan folders live under `.ai/plan/` in the repo's main checkout, shared by every worktree. `research` also investigates bugs and writes findings to `.ai/research/<name>/`, which you can hand to `plan`. A spec checker agent reads each draft spec in a fresh context before you see it. `build` builds the tasks test-first, one commit each, reading only the plan's specs and tasks, plus the branch a split carries code from.

## Scope

In: where specs live, how they're named, written and checked; the spec rules file; tasks from specs; upgrade tasks; splitting a branch; the README's `plan` section.
Out: answering questions and investigating bugs (the research spec); how `build` commits specs and carries a split branch's code (the build spec); how the spec checker works (the spec-checker spec); the `upgrades.md` walk, its withdraw list and the `upgrades:` status line; an upgrade-only request that fits one PR, which `build` takes; epics; a `spec.md` that defines no area; per-repo folders for two repos' specs with one area name.

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

Scenario: A spec says what and why, and its tasks say how
  Given research shows auth's LockoutService should keep lockouts in Redis
  When you plan login lockout
  Then the spec says a locked-out user sees when they can try again, and why
  And only the tasks name LockoutService and Redis

Scenario: Tasks cover only what changed
  Given a plan edits one of daily.md's scenarios and adds another
  When plan writes tasks
  Then those two scenarios are the acceptance criteria, and daily's unchanged scenarios aren't

Scenario: Only behaviour a spec removes gets a "gone" task
  Given a plan's daily.md drops a scenario whose behaviour its Scope's Out names
  And it slims away another scenario whose behaviour still holds
  When plan writes tasks
  Then a task checks that the first behaviour is gone, and no task covers the second

Scenario: A bug goes to research first
  When you ask plan to fix checkout returning 500 on empty carts
  Then research investigates it, and plan plans the fix from its findings

Scenario: An upgrade the change needs becomes a task
  Given research shows refunds need stripe 16's refund API, and the repo is on stripe 14
  When plan writes tasks
  Then the first task of the MR that needs it upgrades stripe to 16
  And no spec mentions the upgrade

Scenario: Split a branch that grew too big
  Given feat/big-cart mixes a refactor, a feature and a config change, and bumps stripe from 14 to 16
  When you ask plan to split feat/big-cart
  Then it writes the specs for what the branch does and tasks for the refactor, the feature stacked on it, and the config change
  And each task names the files or hunks it carries from feat/big-cart
  And a task first redoes the stripe bump, carrying none of the branch's lockfile hunks
```

## Design

**Specs.** `docs/specs/` holds one spec per domain area (a skill, an agent, an area of an app), named for it, with no sub-folders. The spec rules file, `skills/plan/spec-file.md`, says what a spec holds: what its area does, as its users and callers see it, and why, but never how it's built. An existing spec's Design section goes the next time its spec is rewritten: its what and why move into the other sections, and the rest is dropped. Behaviour a test already pins stays out unless it's arbitrary, there's one scenario per behaviour, and Decisions keep only the arbitrary ones and the ones a later change could undo without knowing why. Scope's Out names each behaviour a change removes.

Once `same-page` agrees something broken is to be tracked down, `plan` invokes `research`, which hands its findings path back to `plan` rather than suggesting `build`; `plan` then plans the recommended fix, reusing research's notes.

After `same-page`, `plan` works out which areas the request touches and writes each one's spec in the plan folder as `specs/<area>.md`. An area with a spec starts from a copy of it at the base branch's fetched tip, brought wholly up to the rules; a new area holds only what this change defines. Each spec goes through the spec checker, then the walk: `plan` takes you through its path, decisions and open questions, raising any checker finding still open, and asks you to approve or change it. It's approved only when you say so. The plan's status then reads `spec: approved <date>: <repo>@<commit> <path>, …`, naming each spec, the repo it ships in and the base commit its copy came from. The specs stay in the plan folder until `build` commits them. When `build` hands a plan back because a spec changed on the base, `plan` starts that spec again from the base's current version, merges its own changes in, checks and walks the changes, and records the new commit.

**Tasks** come from what the specs change since their recorded commit: every scenario of a new spec; for an edited one, each scenario added or whose behaviour changed, each removed scenario whose behaviour Scope's Out names (checking it's gone), and each other behaviour change no scenario covers (an observable check). Anything slimmed away, reworded or merged gets no task; removed behaviour gets a "gone" check only when Scope's Out names it. Each task says how it builds its criteria (components and where they live, interfaces, data, errors and tests, with the reason for any choice a later change could undo), drawn from research, findings, the code and your choices. The criteria come only from the specs, with two exceptions: a split branch's diff (below), and upgrades. `plan`'s research reads the version in use of each dependency the change touches; one the change needs newer (for an API it uses, a bug it would hit, a security fix, or a deprecated version its new code would build on) becomes its own task, first in the MR that needs it, or its own MR first when its breaking changes reach code the change doesn't touch. That task names the package, both versions, why, and each breaking change with where; its checks are `<package> <to>: suite passes (the bump is config: no new test)` and a test for each breaking change it handles. A request that's only an upgrade, which `build` hands over because it outgrows one PR, gets no spec (`spec: none`): research, then upgrade tasks.

**Splitting a branch.** The branch's diff against the default branch, from where they diverge, is the request; the plan's status gets `from: <branch>`. The specs cover what the branch does, and each task's file names the branch in `from:` and lists what it carries: whole files, or hunks by path and what they change. Every hunk goes to exactly one task, or the final reply names it as left out. A task that changes no behaviour has one acceptance criterion, "suite passes (no behaviour change: no new test)". A version bump on the branch becomes its own task, first, which redoes the manifest and lockfile change, naming their hunks as redone rather than carried or left out, and then carries the hunks that adapt code to it. When `build` finds a task's carried code doesn't work alone, `plan` moves the hunks it needs into that task, or reorders tasks, rewriting only uncommitted ones. `plan` never changes, rebases or deletes the branch.

**Folder.** `specs/`, `status.md` (ticket, spec, `from:`, each MR's progress), `research/` and `tasks/`. Related repos come from the main checkout's `CLAUDE.md` and `CLAUDE.local.md`, through the shared `related-repos.sh`.

The README's `plan` section describes living specs, the spec checker and splitting a branch, and sends bugs and questions to `research`.

Testing: the repo's check script and markdownlint; planning a change to an existing spec, to a new area, and one that slims a spec; splitting a sample branch with a version bump.

## Decisions

- **One living spec per domain area, in a flat folder, named for the area**: Why: one place per area that changes whenever the area does. Not a spec per change: it goes stale the moment the next change lands. Not sub-folders per plan: they name history, not areas.
- **Specs say what and why; tasks say how**: Why: a spec is what you approve and what every later plan reads, and implementation detail buries that, while the how only matters to the build that writes it, and the code records it after that. Not a Design section in each spec: it pulled specs into implementation.
- **Specs stay in the plan folder until `build` commits them**: Why: the plan folder is shared by every checkout, while `docs/specs/` belongs to whichever branch is checked out. Not moving them into `docs/specs/` on approval: a build in another worktree wouldn't see them.
- **Only what matters goes in a spec**: Why: tests already pin most behaviour, and a spec that records every decision outgrows the code it describes. Not every decision made along the way.
- **Only behaviour Scope's Out names gets a "gone" task**: Why: slimming a spec removes scenarios whose behaviour still holds, and a task proving them gone would break them. Not a task for every removed scenario.
- **Upgrades are tasks, never a spec or a separate walk**: Why: a spec says what an area does whatever versions you pick, and research already shows what the change needs. Not an `upgrades.md` with its own approval: a second walk for what the task list already shows.
- **A split branch's version bump is redone, not carried**: Why: lockfile hunks rarely apply once the base has moved. Not carrying the hunk.
- **A no-behaviour task, or a version bump, is marked by its suite-check criterion's fixed wording**: Why: `build` needs to know when no failing test is possible, and the task format already holds criteria. Not a new field.
- **An upgrade-only request needs no spec**: Why: it changes no area's behaviour. Not an empty spec.
- **No epics**: Why: a separate plan per feature does the same with one less layer to track. Not an epic folder holding features.
