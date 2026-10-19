# Research

`research` finds something out and reports it with citations, changing nothing. A plain question gets a report in the chat; something broken gets a proven cause, with ways to fix it, in a findings file you can hand to `plan` or `build`.

## Context

Questions are answered from the code, docs, the web and connected tools, preferring the repo's existing patterns over generic advice and reading versions from manifests and lockfiles before external docs. Bugs are investigated with whatever the repo's `## Debug tools` section lists (in the main checkout's `CLAUDE.md` or `CLAUDE.local.md`, which `setup` writes) and the Related repos `setup` links. The debug checker (its own spec) challenges each claimed cause. Working files live under `.ai/` in the repo's main checkout, shared by every worktree; in a worktree session, `research` writes there the way the ai-folder spec says. `plan` and `prompt-writer` hand it questions they've already agreed with you, and `build` hands over a CI test that fails in CI but passes locally.

## Scope

In: questions, including ones only an experiment answers; bugs, errors, failing tests, incidents and alerts; questions `plan` and `prompt-writer` hand over; tests `build` hands over; the findings file; calling the debug checker; the README's `research` section, which covers questions, experiments and bugs, with the Debug tools example.
Out: fixing anything; planning the fix (`plan`); building it (`build`).

## Behaviour

```gherkin
Scenario: A plain question
  When you ask which Next.js version shop is on
  Then research replies with a report and writes no files
  And the report gives the request, the answer, assumptions, adjacent findings and what wasn't found, each claim cited by path and line, URL, or command and output

Scenario: A question only trying can answer
  When you ask whether swapping moment for date-fns in shop breaks anything
  Then research makes the swap in a throwaway worktree and runs shop's tests there
  And the report cites each command it ran and what it printed
  And it removes the worktree and stops what it started, so nothing of the experiment is kept and your checkout is unchanged

Scenario: A question with several readings
  When you ask research to look into auth
  Then it agrees with you on what you mean before looking anything up

Scenario: A question another skill hands over
  Given plan has agreed with you what it needs to know
  When it hands research the question
  Then there's no same-page round
  And the report is saved in the plan's research/ folder and goes back to plan

Scenario: A bug's cause is proven
  Given checkout returns 500 on empty carts
  When you ask research why
  Then it works in .ai/research/<name>/ in the main checkout, <name> being 2 to 4 kebab-case words no other folder there uses
  And it walks the failing path in research/path.md there, a line per step citing what it read or marked assumed, with a note per lead as research/<lead>.md
  And it reproduces the failure in a throwaway worktree, at HEAD plus your uncommitted changes when the bug needs them, and shows it passes with only the cause patched out
  And the debug checker's verdict on the cause sets its confidence
  And it writes findings.md there, for someone who saw none of it, with the cause, its proof and confidence, and ways to fix it with a recommendation
  And it removes the worktrees it made and stops the processes it started
  And nothing in your checkout changes, and no branch is made

Scenario: Reading outside the repo
  Given the bug needs logs from production and errors from the error tracker
  When research investigates it
  Then it only reads there, and redacts secrets and personal data from what it writes

Scenario Outline: The debug checker's verdict
  Given the debug checker <verdict> the claimed cause
  When research carries on
  Then <next>

  Examples:
    | verdict           | next                                                                        |
    | names gaps in     | research checks those gaps and asks it again, at most twice                  |
    | rejects           | research moves to the next cause, or the findings say none holds             |

Scenario: A cause it can't reproduce
  Given research can't make the failure happen
  When it writes the findings
  Then it can still report the likeliest cause, at most at medium confidence

Scenario Outline: What the reply suggests
  Given the findings recommend <fix>
  When research replies
  Then it gives the findings' path and the cause, and suggests <next> with the findings

  Examples:
    | fix                                        | next  |
    | a fix that fits one PR, with nothing left to decide | build |
    | anything bigger, or with choices left      | plan  |

Scenario: A test build hands over
  Given build hands over a checkout test that failed in CI on PR 45 and passed locally, with the CI job's log and PR 45's commits
  When research investigates it
  Then there's no same-page round, and the findings folder is the test's name in kebab case plus PR 45's number, so build finds it again while landing PR 45
  And findings for that test from other PRs are leads it rules in or out, never the answer
  And it runs the test alone up to 50 times at PR 45's head, then the whole suite in CI's order up to 5 times, stopping at the first failure
  And a failure it reproduces is rerun the same way at PR 45's base, so the findings say whether PR 45 caused it
  And a flaky cause is proven by the patched code passing those same runs
  And the findings path goes back to build, which carries on landing

Scenario: A test that fails only in CI
  Given the handed-over test passes every one of those runs
  When research investigates it
  Then it looks for what differs between CI and your machine, as an ordinary bug
  And if it still can't reproduce the failure, the findings say so, at most at medium confidence
```

## Decisions

- **Questions and debugging in one skill, outside `plan`**: Why: both find something out and report it, changing nothing, and one skill costs one description in every session; `plan` only plans. Not two skills. Not modes of `plan`.
- **Findings in `.ai/research/<name>/`**: Why: you hand them to `plan` or `build` by path, and a bug may need no plan. Not the plan folder.
- **A plain question writes no files**: Why: the report is the answer. Not a folder per question.
- **A question reading can't settle gets an experiment, thrown away after**: Why: some answers, like what breaks if you swap a library, show up only when you try, and the report's commands and output are the evidence. Not keeping the prototype: it's built to answer the question, not to ship. Not leaving these questions to `plan`, which runs no experiments.
- **Proof by patching only the cause, in a throwaway worktree**: Why: evidence that fits isn't proof, and your checkout stays as it was. Not trusting a plausible cause.
- **50 runs alone, then 5 of the suite**: Why: 50 catches a 1-in-20 flake with high odds and is quick for one test; a few suite runs catch flakes that need other tests first. Not unlimited.
- **A reproduced flake is rerun at the base**: Why: whether the PR caused it decides where the fix goes. Not guessing from the diff.
