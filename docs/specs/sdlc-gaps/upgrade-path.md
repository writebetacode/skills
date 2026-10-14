# Upgrade path in plan

When `plan` has an approved spec, it now checks the dependencies the feature touches and proposes the upgrades worth doing as part of it, in a file of its own that you trim before anything is locked in. Today a feature gets built on whatever versions the repo has, even when a newer one has the API it needs or fixes a bug it would hit, and nobody notices until review or later.

## Context

`plan` talks the request through, researches how things work here (including versions in use), writes a spec, walks it with you and, on approval, moves it to `docs/specs/` and splits it into one task file per MR. Tasks are written from the spec alone. `build` then builds each task test-first, reading only the spec and the task files.

`review` already has a way to drop items you don't want: each finding is numbered in a file, and you move one under a `## Withdrawn` heading, or say "withdraw" and its number. Nothing withdrawn is ever posted.

## Scope

In: a new `plan` step between spec approval and tasks; its file, `upgrades.md`, in the plan folder; turning approved upgrades into tasks; an `upgrades:` line in `status.md`; the README.
Out: upgrading dependencies the feature doesn't touch; upgrades outside `plan`; changing `build` beyond sending a plan with an unapproved upgrade list back to `plan`.

## Behaviour

```gherkin
Scenario: Propose upgrades that serve the feature
  Given an approved spec for refunds, the repo on stripe 14, and stripe 16 adding the refund API the spec needs
  And eslint is two majors behind
  When plan reaches the upgrade step
  Then upgrades.md proposes stripe 14 to 16, saying why the feature needs it, the breaking changes that hit this repo with where, and which MR it ships in
  And eslint isn't mentioned

Scenario: Nothing worth upgrading
  Given every dependency the feature touches is current or an upgrade wouldn't help it
  When plan reaches the upgrade step
  Then no upgrades.md is written and status.md says upgrades: none

Scenario Outline: Withdraw an upgrade
  Given upgrades.md proposes upgrades 1 and 2
  When you <action>
  Then upgrade 2 sits under Withdrawn and never becomes a task

  Examples:
    | action                               |
    | say "withdraw 2"                     |
    | move upgrade 2 under Withdrawn       |

Scenario: Lock in on approval
  Given you've withdrawn what you don't want
  When you approve the upgrades
  Then status.md records upgrades: approved with the date
  And tasks are written only after that

Scenario: Upgrades ship inside the feature where they can
  Given an approved upgrade the first MR's code depends on
  When plan writes tasks
  Then the upgrade is the first task of that MR

Scenario: An upgrade too big to ride along
  Given an approved upgrade whose breaking changes reach code the feature doesn't touch
  When plan writes tasks
  Then the upgrade gets its own MR, merged before the feature's MRs

Scenario: The spec stays clean
  When plan writes upgrades.md
  Then the spec doesn't mention the upgrades
```

## Design

A new step in `plan`, after the spec is approved and before tasks:

1. From the research on versions in use, take each dependency the spec's design touches. For each, find the latest stable version (the package registry's CLI, else its release notes on the web) and read the changes between the two.
2. Propose an upgrade only when it serves this feature: an API the feature needs, a bug it would hit, a security fix, or a version so old the new code would be built on something deprecated. Everything else stays out.
3. Write `upgrades.md` in the plan folder, numbered like a review: a heading per upgrade with the package and both versions, why the feature needs it, the breaking changes that touch this repo with where they are, and where it ships (inside a named MR, or in its own MR before them). `## Withdrawn` holds what you drop. No upgrades → no file.
4. Walk it like the spec, in a few lines: each upgrade and where it ships. You withdraw by moving one under `## Withdrawn` or saying "withdraw" and its number; other changes are edited in and walked again. Explicit approval locks it in: `status.md` gets `upgrades: approved` and the date (or `none`, or `draft` while it's being walked).

The task writer reads approved upgrades as well as the spec, skipping anything withdrawn. Each approved upgrade becomes the first task of the MR it ships in, or its own MR numbered before the feature's MRs when it ships alone. Its checks: the repo's suite passes on the new version, and each breaking change listed is handled. The task carries everything `build` needs, so `build` still reads only the spec and tasks.

When a revision changes which dependencies the design touches, the upgrade step runs again for the new ones before tasks are rewritten, keeping the approved upgrades and their numbers and walking only the new ones. A plan left at an unapproved upgrade list picks up at that walk: `plan` resumes it, and `build` sends it back to `plan`.

An upgrade task's version bump counts as config: the existing suite is its check, with no new test, while each breaking change it handles gets a test as usual.

The README's `plan` section mentions the upgrade step.

Testing: the repo's check script (budgets and links), and a dry run of `plan` on a small feature in a scratch repo with an outdated dependency.

## Decisions

- **After spec approval, before tasks**: Why: the design has to be settled to know which dependencies it touches, and tasks need to know what's upgraded. Not during research: the design isn't agreed yet.
- **Outside the spec, in `upgrades.md`**: Why: the spec says what to build and stays true whichever versions you pick; upgrades are a delivery choice. Not a spec section.
- **`review`'s withdraw mechanic**: Why: you already know it, and editing a file is quicker than answering questions about each upgrade. Not one question per upgrade.
- **Only dependencies the feature touches, and only when it helps**: Why: unrelated upgrades bloat the feature's MRs and its review. Not a general outdated-dependency report.
- **`build` sends an unapproved upgrade list back to `plan`**: Why: otherwise a plan paused at the upgrade walk has no tasks, and `build` would close it as finished. Not leaving `build` untouched: the pause is new, so its gate has to know about it.
- **Inside the feature's MRs where possible, else just before them**: Why: the user wants upgrades shipped with the feature; an upgrade that reaches unrelated code is safer reviewed on its own. Not always a separate MR.

## Questions

None.
