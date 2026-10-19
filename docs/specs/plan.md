# Plan

`plan` turns a request into specs and tasks you've agreed on before any code exists, so `build` never has to guess. It keeps one living spec per domain area in a flat `docs/specs/`, and it can split a branch that grew too big to review into tasks that reuse its work.

## Context

`plan` agrees on each request with you through `same-page`, one question at a time, then gathers what the specs and tasks need through `research`, saving each report in its plan folder. Plan folders live under `.ai/plan/` in the repo's main checkout, shared by every worktree, each holding `specs/`, `status.md` (the ticket, the specs' approval, the branch a split carries code from, each MR's progress), `research/` and `tasks/`. It reads related repos from the main checkout's `CLAUDE.md` and `CLAUDE.local.md`, which `setup` writes. `research` also investigates bugs and writes findings to `.ai/research/<name>/`, which you can hand to `plan`. A spec checker agent reads each draft spec in a fresh context before you see it. `build` builds the tasks test-first, one commit each, reading only the plan's specs and tasks, plus the branch a split carries code from.

## Scope

In: where specs live, how they're named, written, checked and approved; the spec rules; tasks from specs; upgrade tasks; splitting a branch; the README's `plan` section, which describes living specs, the spec checker and splitting a branch, and sends bugs and questions to `research`.
Out: answering questions and investigating bugs (the research spec); how `build` commits specs and carries a split branch's code (the build spec); how the spec checker works (the spec-checker spec); the `upgrades.md` walk, its withdraw list and the `upgrades:` status line; an upgrade-only request that fits one PR, which `build` takes; epics; a `spec.md` that defines no area; per-repo folders for two repos' specs with one area name.

## Behaviour

```gherkin
Scenario: A change to a defined area updates its spec
  Given docs/specs/daily.md defines daily
  When you plan a new source for daily
  Then the plan's specs/daily.md starts from daily.md as it is on the latest base branch, brought wholly up to the spec rules
  And the plan adds no new spec

Scenario: A new area gets a spec named for it
  Given no spec defines ticket
  When you plan ticket's search before filing
  Then the plan's new spec is specs/ticket.md, defining only that search

Scenario: A spec says what and why, and its tasks say how
  Given research shows auth's LockoutService should keep lockouts in Redis
  When you plan login lockout
  Then the spec says a locked-out user sees when they can try again, and why
  And only the tasks name LockoutService and Redis, with the reason for any choice a later change could undo

Scenario: An old Design section goes when its spec is next rewritten
  Given a shop repo's docs/specs/payments.md still has a Design section
  When you plan a change to payments
  Then the plan's payments.md moves that section's what and why into its other sections and drops the rest

Scenario: You approve each spec
  Given the spec checker has checked the plan's daily.md
  When plan walks you through it
  Then it takes you through its path, decisions and open questions, raising any checker finding still open, and asks you to approve or change it
  And it's approved only when you say so, and status.md records the date, each spec's repo and the base commit its copy came from

Scenario: A plan build hands back
  Given build handed a plan back because daily.md changed on the base branch
  When plan revises it
  Then it starts daily.md again from the base's current version and merges its own changes in
  And it checks and walks you through the changes, then records the new base commit

Scenario Outline: Tasks cover only what changed
  Given a plan <change>
  When plan writes tasks
  Then <tasks>
  And every criterion comes from the specs, apart from a split branch's diff and upgrades

  Examples:
    | change                                                          | tasks                                                                  |
    | adds ticket.md                                                  | each of ticket.md's scenarios is an acceptance criterion               |
    | edits one of daily.md's scenarios and adds another              | those two scenarios are the criteria, and daily's unchanged ones aren't |
    | changes behaviour daily.md states outside its scenarios         | a criterion checks the change as a user would see it                    |
    | rewords and merges daily.md's scenarios, changing no behaviour  | no task covers them                                                    |

Scenario: Only behaviour a spec removes gets a "gone" task
  Given a plan's daily.md drops a scenario whose behaviour its Scope's Out names
  And it slims away another scenario whose behaviour still holds
  When plan writes tasks
  Then a task checks that the first behaviour is gone, and no task covers the second

Scenario: A bug goes to research first
  When you ask plan to fix checkout returning 500 on empty carts
  Then research investigates it and hands its findings back to plan, not to build
  And plan plans the recommended fix, reusing research's notes

Scenario Outline: An upgrade the change needs becomes a task
  Given research shows refunds need stripe 16's refund API, and the repo is on stripe 14
  And stripe 16's breaking changes reach <reach>
  When plan writes tasks
  Then <task>
  And the task names stripe, both versions, why, and each breaking change with where it hits
  And it's checked by the whole suite passing and a test for each breaking change it handles
  And no spec mentions the upgrade

  Examples:
    | reach                                  | task                                                      |
    | only code the change touches           | the first task of the MR that needs it upgrades stripe to 16 |
    | code the change doesn't touch          | an MR of its own, first, upgrades stripe to 16             |

Scenario: A request that's only an upgrade
  Given build handed over upgrading stripe in shop, web and api, because it outgrows one PR
  When plan plans it
  Then research reads what the upgrade needs, and the plan has upgrade tasks and no spec

Scenario: Split a branch that grew too big
  Given feat/big-cart mixes a refactor, a feature and a config change, and bumps stripe from 14 to 16
  When you ask plan to split feat/big-cart
  Then it treats feat/big-cart's changes since it left the default branch as the request
  And it writes the specs for what the branch does and tasks for the refactor, the feature stacked on it, and the config change
  And each task names the files or hunks it carries from feat/big-cart, every hunk in exactly one task or named in the reply as left out
  And the refactor's task, changing no behaviour, is checked by the whole suite alone
  And a task first redoes the stripe bump, carrying none of the branch's lockfile hunks, then carries the hunks that adapt code to stripe 16
  And feat/big-cart is never changed, rebased or deleted

Scenario: Carried code that doesn't work alone
  Given build handed back a split because the feature task's code needs a hunk from a later task
  When plan revises the split
  Then it moves that hunk into the feature task, or reorders the tasks, rewriting only tasks not yet committed
```

## Decisions

- **One living spec per domain area, in a flat folder, named for the area**: Why: one place per area that changes whenever the area does. Not a spec per change: it goes stale the moment the next change lands. Not sub-folders per plan: they name history, not areas.
- **Specs say what and why; tasks say how**: A spec says what its area does, as its users and callers see it, and why, never how it's built. Why: a spec is what you approve and what every later plan reads, and implementation detail buries that, while the how only matters to the build that writes it, and the code records it after that. Not a Design section in each spec: it pulled specs into implementation.
- **Specs stay in the plan folder until `build` commits them**: Why: the plan folder is shared by every checkout, while `docs/specs/` belongs to whichever branch is checked out. Not moving them into `docs/specs/` on approval: a build in another worktree wouldn't see them.
- **Only what matters goes in a spec**: behaviour a test already pins stays out unless it's arbitrary, there's one scenario per behaviour, and Decisions keep only the arbitrary ones and the ones a later change could undo without knowing why. Why: tests already pin most behaviour, and a spec that records every decision outgrows the code it describes. Not every decision made along the way.
- **Scope's Out names each behaviour a change removes, and only that gets a "gone" task**: Why: slimming a spec removes scenarios whose behaviour still holds, and a task proving them gone would break them. Not a task for every removed scenario.
- **Upgrades are tasks, never a spec or a separate walk**: `plan`'s research reads the version in use of each dependency the change touches, and one the change needs newer (for an API it uses, a bug it would hit, a security fix, or a deprecated version its new code would build on) becomes a task. Why: a spec says what an area does whatever versions you pick, and research already shows what the change needs. Not an `upgrades.md` with its own approval: a second walk for what the task list already shows.
- **A split branch's version bump is redone, not carried**: Why: lockfile hunks rarely apply once the base has moved. Not carrying the hunk.
- **A no-behaviour task, or a version bump, is marked by its suite-check criterion's fixed wording**: `suite passes (no behaviour change: no new test)`, or `<package> <to>: suite passes (the bump is config: no new test)`. Why: `build` needs to know when no failing test is possible, and the task format already holds criteria. Not a new field.
- **An upgrade-only request needs no spec**: Why: it changes no area's behaviour. Not an empty spec.
- **No epics**: Why: a separate plan per feature does the same with one less layer to track. Not an epic folder holding features.
