# Review

`review` gives you a careful review of a pull or merge request that you edit before anyone sees it, and it holds every PR to the repo's specs, so code and specs never drift apart: wherever the code no longer matches a spec the PR didn't update, the PR is blocked with a question. Comments on a PR you wrote go to `build` instead, since they call for code changes, not a review.

## Context

Specs in `docs/specs/` are the living definition of each domain area, and every change to an area updates its spec in the same change. They describe behaviour and decisions by area; they aren't indexed by the files they cover.

`review` reads a PR's code, and anything else from the repo, in a detached worktree at the PR's head, so a spec the PR changed reads as changed. It gathers the ticket, the PR description, the diff, the code around it and the repo's rules. A finding is blocking for broken behaviour, security or breakage elsewhere; a checker agent then rechecks each finding in a fresh context and downgrades blocking findings outside that bar. Findings are worded as questions about the code, never the person; the checker's own rules live in its spec. `build` runs the same review steps on its own uncommitted changes, after writing its plan's specs into `docs/specs/`. `review` runs remote commands only from its host tables; `pr`'s tables hold the command that returns your login.

## Scope

In: specs in review's context; spec mismatches as blocking findings; sending comments on your own PR to `build`; the README's `review` section; marking "Spec clashes in `review`" Done in `docs/proposed-improvements.md`.
Out: reviewing a spec on its own; specs whose area the diff doesn't touch; how the review checker treats these findings (the review-checker spec).

## Behaviour

```gherkin
Scenario: A PR that contradicts a spec is blocked
  Given docs/specs/auth.md says sessions last 1 hour
  And a PR makes sessions last 24 hours without changing auth.md
  When you review the PR
  Then a blocking finding asks: "auth.md says sessions last 1 hour. Should it say 24 now, or should this stay at 1?"

Scenario: A spec edited elsewhere still counts
  Given a PR edits auth.md's password section and makes sessions last 24 hours
  And auth.md still says sessions last 1 hour
  When you review the PR
  Then a blocking finding asks about the session length

Scenario: Work a later PR of the plan will do isn't flagged
  Given auth.md already says 24 hours, and the PR's merge order names the later PR that makes it so
  And this PR keeps sessions at 1 hour
  When you review the PR
  Then there is no finding about the session length

Scenario: A spec updated with the code is fine
  Given a PR makes sessions last 24 hours and changes auth.md to say 24 hours
  When you review the PR
  Then there is no finding about auth.md

Scenario: An improvement is still blocked until the spec matches
  Given a spec's design says to retry 3 times
  And a PR retries 5 times with backoff, explains why, and leaves the spec alone
  When you review the PR
  Then a blocking finding asks whether the spec should now describe the backoff

Scenario: Build's own reviews check specs too
  Given build's uncommitted changes contradict docs/specs/auth.md
  When build reviews them before you commit
  Then the review finds the same blocking mismatch

Scenario: Comments on your own PR go to build
  Given you wrote PR 45 and a reviewer commented on it
  When you ask Claude to address the comments on PR 45
  Then build lands it instead of review
```

## Design

Related repos come from the `CLAUDE.md` and `CLAUDE.local.md` of the repo's main checkout (found by the shared main-checkout script), wherever `review` runs, with each path resolved from that checkout.

The context step also gathers the specs in `docs/specs/` that share the diff's area, found by searching them for the diff's key terms (skill and feature names, behaviours, settings, paths), read from the PR's worktree, or from the checkout for a local review.

The blocking bar gains a fourth case: code that no longer matches a part of a spec (a scenario, Design text or a Decision) the PR didn't update. The finding asks which should change, the code or the spec, in review's usual tone, citing the spec's line. A mismatch that a later task or PR of the same plan will close isn't a finding, when `build`'s brief or the PR's merge order names that later work.

Asked to address a PR's comments, `review` compares the PR's author (from `view`) with your login, from `pr`'s `user` command, which review's rule on remote commands names alongside its own tables. A PR you wrote goes to `build`'s land step, and `review` stops. The check applies only to that ask: a review or re-review, `daily`'s included, always runs as one.

The README's `review` section says it holds PRs to the repo's specs, and the row above moves to Done.

Testing: the repo's check script and markdownlint, and a review of a sample PR that contradicts a spec.

## Decisions

- **Every spec mismatch is blocking, asked as a question**: Why: specs must always match the code, and either fix is small. Not non-blocking for improvements: a stale spec misleads the next plan just the same.
- **Either fix clears it, with no reason required**: Why: what matters is that code and spec agree; the spec's own rules ask for a why only when a Decision changes. Not demanding the PR explain every spec edit.
- **Specs found by area, not path**: Why: specs are written by area and aren't indexed by the files they cover. Not a path index: every spec would have to list and keep up every file it touches.
- **Comments on your own PR go to `build`**: Why: they need code changes and reply drafts, which is landing. Not `review`: it answers replies to its own findings on PRs you reviewed.
