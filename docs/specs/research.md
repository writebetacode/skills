# Research

`research` finds something out and reports it with citations, changing nothing. A plain question gets a report in the chat; something broken gets a proven cause, with ways to fix it, in a findings file you can hand to `plan` or `build`.

## Context

Questions are answered from the code, docs, the web and connected tools, preferring the repo's existing patterns over generic advice and reading versions from manifests and lockfiles before external docs. Bugs are investigated with whatever the repo's `## Debug tools` section lists (in the main checkout's `CLAUDE.md` or `CLAUDE.local.md`, which `setup` writes) and the Related repos `setup` links. Working files live under `.ai/` in the repo's main checkout, shared by every worktree. `build` hands over a CI test that fails in CI but passes locally.

## Scope

In: questions; bugs, errors, failing tests, incidents and alerts; tests `build` hands over; the findings file; calling the debug checker; `prompt-writer`'s pointer to these rules; the README's `research` section.
Out: fixing anything; planning the fix (`plan`); building it (`build`).

## Behaviour

```gherkin
Scenario: A plain question
  When you ask which Next.js version shop is on
  Then research replies with a cited report and writes no files

Scenario: A question with several readings
  When you ask research to look into auth
  Then it agrees with you on what you mean before looking anything up

Scenario: A bug's cause is proven
  Given checkout returns 500 on empty carts
  When you ask research why
  Then it reproduces the failure in a throwaway worktree and shows it passes with only the cause patched out
  And it writes .ai/research/<name>/findings.md with the cause, its proof and confidence, and ways to fix it with a recommendation
  And nothing in your checkout changes

Scenario: A test build hands over
  Given build hands over a checkout test that failed in CI on PR 45 and passed locally
  When research investigates it
  Then there's no same-page round
  And it runs the test alone up to 50 times at PR 45's head, then the whole suite in CI's order up to 5 times
  And a failure it reproduces is rerun the same way at PR 45's base, so the findings say whether PR 45 caused it
  And the findings path goes back to build

Scenario: A test that fails only in CI
  Given the handed-over test passes every one of those runs
  When research investigates it
  Then it looks for what differs between CI and your machine, as an ordinary bug
```

## Design

`skills/research/` holds the skill (the question rules and report template), `investigate.md` (the debug path), `findings-file.md` and `handover.md`. The debug checker (its own spec) challenges a claimed cause.

**Questions.** One reading → research it; several → `same-page` first. Independent lines too big to read alone go to parallel read-only subagents. The report has fixed sections (the request, the answer, assumptions, adjacent findings, what wasn't found), each claim cited by `path:line`, URL, or command and output. Called by `plan` or `prompt-writer`, which have already agreed the request with you, a question or bug gets no `same-page` round, and the report (saved in a plan's `research/`) or the findings path goes back to the caller.

**Bugs.** A folder `.ai/research/<name>/` in the main checkout, `<name>` 2–4 kebab-case words not already there, holds the notes and `findings.md`. Outside the repo it only reads, and it redacts secrets and personal data. Inside that folder, it walks the failing path in `research/path.md`, a line per step citing what it read or marked `assumed`, and keeps a note per lead as `research/<lead>.md`. Experiments run only in a throwaway worktree under the temp folder, at `HEAD` plus your uncommitted changes when the bug needs them, never your checkout, and make no branches. A cause is proven only when the repro fails, then passes with only that cause patched out; one it can't reproduce can still be reported, at most medium confidence. The debug checker gets only paths and its verdict sets the confidence; gaps it names are checked and it reruns, at most twice. A cause it rejects sends `research` to the next one, or the findings say none holds. Then the worktrees it made are removed and the processes it started stopped. The findings are written for someone who saw none of it. The reply gives their path and the cause; a fix that fits one PR with nothing left to decide → it suggests `build` with the findings, else `plan`.

**A test from `build`** comes with the job and its log, and the PR's branch, head and base commits. The folder is the test's name in kebab case, so `build` can find it again, and the worktree starts at the head, moving to the base for the rerun. The runs above stop at the first failure; flaky → the cause is proven with the patched code passing the same runs. Still no repro → the findings say so, confidence at most medium. The reply goes to `build`, which carries on landing.

In a worktree session, `research` carries the ai-folder spec's line for a refused write.

The README's `research` section covers questions and bugs, with the Debug tools example.

Testing: the repo's check script and markdownlint; a version question; a planted bug and a planted flaky test in a scratch repo.

## Decisions

- **Questions and debugging in one skill, outside `plan`**: Why: both find something out and report it, changing nothing, and one skill costs one description in every session; `plan` only plans. Not two skills. Not modes of `plan`.
- **Findings in `.ai/research/<name>/`**: Why: you hand them to `plan` or `build` by path, and a bug may need no plan. Not the plan folder.
- **A plain question writes no files**: Why: the report is the answer. Not a folder per question.
- **Proof by patching only the cause, in a throwaway worktree**: Why: evidence that fits isn't proof, and your checkout stays as it was. Not trusting a plausible cause.
- **50 runs alone, then 5 of the suite**: Why: 50 catches a 1-in-20 flake with high odds and is quick for one test; a few suite runs catch flakes that need other tests first. Not unlimited.
- **A reproduced flake is rerun at the base**: Why: whether the PR caused it decides where the fix goes. Not guessing from the diff.
