# Build

`build` builds what's already decided (a plan's tasks, findings, or a small request with nothing in doubt) test-first into reviewed PRs, then lands them. Anything in doubt goes to `plan`, because settling what to build is planning. Whatever its change makes untrue in a spec, README or other doc gets fixed in the same commit, without asking.

## Context

For each task, `build` writes a test per acceptance criterion that fails for the reason the criterion names, then the least code that passes. Each change goes through `review` and the review checker before you see it. Landing rebases the PRs, fixes failing CI from the job logs and drafts replies to review comments. `build` waits for your go before it commits, pushes or posts.

`plan` hands it a plan folder, shared by every checkout (bare repos aside), holding the approved specs, the repo and base commit each spec's copy came from, and the tasks; a split's tasks name the branch they carry code from and list what they carry. `research` hands it findings with a recommended fix, and investigates the CI failures `build` hands over.

## Scope

In: which requests `build` takes; committing a plan's specs; split tasks; upgrade tasks; CI failures that pass locally; PRs you didn't write; fixing the docs a change makes untrue; closing a plan; the README's `build` section, which says unclear work goes to `plan` first, a CI test that passes locally goes to `research` and an older one is reported with its findings, and `build` fixes the docs its changes make untrue.
Out: how `plan` splits a branch and how `research` investigates (their specs); building an older flaky test's fix while landing another PR; epics; plans waiting on an `upgrades: draft` walk, which `plan` no longer writes.

## Behaviour

```gherkin
Scenario Outline: An exact request is built directly
  When you ask build to <request>
  Then build builds it without asking you anything first

  Examples:
    | request                                             |
    | fix the typo on line 3 of the README                |
    | upgrade lodash in shop to 4.17.21, as daily suggested |

Scenario Outline: Anything in doubt goes to plan
  When you ask build to <request>
  Then build hands the request to plan and builds nothing

  Examples:
    | request                                  |
    | make checkout faster                     |
    | rename the Cart class across four repos  |
    | upgrade stripe from 14 to 16 in shop, web and api |

Scenario: Findings are built like a request
  Given .ai/research/empty-cart-500/findings.md recommends a fix that fits one PR
  When you ask build to build them
  Then the recommended fix is the task, and the findings' repro is its first test

Scenario: Each change is reviewed before you commit
  Given build's change for a task passes its tests
  When build reviews it
  Then a fresh review checks it against the task and the plan's specs, the findings, or the request, knowing which later tasks and MRs of the plan are still to come
  And build fixes each finding the review checker confirms and reviews again, at most three rounds, before asking for your go

Scenario: Docs a change makes untrue are fixed with it
  Given the README and docs/specs/checkout.md both describe the --express flag
  When you ask build to rename --express to --fast
  Then the same commit updates the README and that spec, and any doc, docstring or comment naming --express, without asking you
  And the changelog's older entries still say --express

Scenario: A change never rewrites the plan's own specs
  Given a plan's approved spec says sessions last 1 hour
  When build's change for a task makes them last 24 hours
  Then build fixes its change to match the spec, or hands the plan back to plan, and leaves the spec as approved

Scenario: A plan's specs ship from the checkout that builds it
  Given a plan made in ~/code/shop, with an approved new spec and an edited one
  When you build its first task in a worktree of shop
  Then both specs are written into the worktree's docs/specs/ before that task's tests, and its commit includes them
  And each is linted with shop's own Markdown rules, if it has some, and the plan's copy updated to match, so a later task doesn't write it again

Scenario Outline: A spec that changed on the base since planning
  Given a plan edited docs/specs/daily.md
  And after the plan was made, <change>
  When build starts the plan's next task
  Then <result>

  Examples:
    | change                                                        | result                                                    |
    | someone changed daily.md on the base branch                   | it hands the plan back to plan to revise and builds nothing |
    | an MR of an earlier revision of this plan changed daily.md     | it hands the plan back to plan to revise and builds nothing |
    | an earlier MR of this plan merged daily.md just as planned    | it builds the task                                        |

Scenario: A task that changes no behaviour
  Given a plan's task changes no behaviour
  When build builds it
  Then the whole suite passing is its check, with no new test

Scenario: An upgrade task
  Given a plan's task upgrades stripe from 14 to 16 and handles one breaking change
  When build builds it
  Then it upgrades stripe with the package manager, and the whole suite must pass
  And it writes a failing test for the breaking change before handling it

Scenario: A split task carries the branch's code and tests
  Given plan split feat/big-cart
  When build builds the feature's task
  Then the task's tests come from feat/big-cart and fail before its code is added, and its code makes them pass
  And a carried test that passes before the code gets a failing test of build's own beside it
  And changes made on the base since feat/big-cart branched off stay
  And feat/big-cart itself is left unchanged

Scenario: Split tasks with no new tests
  Given plan split feat/big-cart into tasks including a refactor that changes no behaviour and a stripe bump
  When build builds them
  Then the refactor's code is carried and checked by the whole suite
  And the stripe bump is redone with the package manager before the hunks that adapt code to it are carried

Scenario: Carried code that doesn't work alone goes back to plan
  Given the feature task's code from feat/big-cart needs a hunk the split put in a later task
  When build runs the task's tests, or the whole suite
  Then it puts the carried code back, hands the plan back to plan to revise the split, and commits nothing

Scenario: A CI failure this PR causes is fixed on the PR
  Given CI fails a checkout test on PR 45 that passes when build runs it locally
  When build lands PR 45
  Then it hands the failure to research, with the CI job's log and PR 45's commits, without asking you
  And once the findings blame PR 45's change, it fixes it test-first on PR 45's branch and carries on landing

Scenario Outline: A CI failure PR 45 didn't cause is reported
  Given the findings for PR 45's failing test show <finding>
  When build carries on landing PR 45
  Then it reports PR 45's CI as red from that test, with the findings' path, and builds no other fix

  Examples:
    | finding                                  |
    | it fails the same way on PR 45's base    |
    | it fails only because of how CI differs  |
    | no cause                                 |

Scenario Outline: A test research already looked into
  Given .ai/research/ holds findings for the checkout test, made while landing <pr>
  When CI fails that test on PR 45
  Then <next>

  Examples:
    | pr     | next                                                                        |
    | PR 45  | build uses those findings and doesn't hand the test to research again      |
    | PR 30  | build hands the test to research, with PR 30's findings as a lead to check |

Scenario: A PR you didn't write goes to review
  Given someone else wrote PR 50
  When you ask build to land PR 50
  Then it hands PR 50 to review and changes nothing

Scenario: Closing a plan cleans up its branches
  Given every MR of a plan has merged
  When build closes the plan
  Then it cleans up each MR branch the way pr does after a merge, and offers to move the plan folder into completed/
```

## Decisions

- **`build` never asks what you mean**: Why: its job is to build what's decided; doubt means planning isn't finished. Not a `same-page` round inside `build`.
- **One PR's worth for a direct request, with nothing in doubt**: what changes, where, and what done looks like. Why: splitting work into PRs is planning, however exact the request. Not one task of any size.
- **`build` fixes stale docs itself, but never history or the plan's own specs**: Why: whoever makes a change knows best what it made untrue, while a changelog records what was true then and a plan's specs are what the code must match. Not flagging docs for you to fix by hand.
- **The plan's specs ship with its first commit**: Why: specs ship with the first change that relies on them, from whichever checkout builds it. Not a commit of their own first.
- **A spec changed on the base goes back to `plan`**: Why: overwriting it would silently undo someone's change. Not merging the two by hand in `build`. Not telling `build`'s own earlier commits apart: a revise after a merged MR rarely happens, and the extra hand-back costs one revise.
- **`build` stays in your worktree**: Why: you chose to work there, and switching the main checkout would change the branch under another session.
- **A split task carries the existing code and tests**: Why: the work is done and tested; a carried test that already passes gets a failing one beside it so the task still proves its change. Not rebuilding from scratch.
- **The split's branch is never touched**: Why: it's the only complete copy until every piece merges, and you decide when it's safe to delete. Not cleaning it up with the merged MR branches.
- **A failing test's findings are reused only for the PR they were made for**: Why: a test can fail on a later PR for a new reason, and old findings would answer with the old cause. Not reusing them for any PR. Not researching again on each CI round of the same PR.
- **An older flaky test is only reported**: Why: its fix is separate work you start from the findings, and building it mid-landing mixes unrelated work into the run. Not opening a fix PR of its own unasked.
- **PRs you didn't write go to `review`**: Why: you can't push to someone else's PR as yours. Not landing them.
