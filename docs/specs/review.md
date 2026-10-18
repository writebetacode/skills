# Review

`review` gives you a careful review of a pull or merge request that you edit before anyone sees it, and it holds every PR to the repo's specs, so code and specs never drift apart: wherever the code no longer matches a spec the PR didn't update, the PR is blocked with a question.

## Context

Specs in `docs/specs/` are the living definition of each domain area, and every change to an area updates its spec in the same change. They're written by area, not indexed by the files they cover. `review` reads a PR's code in a detached worktree at the PR's head, so a spec the PR changed reads as changed, and keeps its findings in a gitignored review file in the main checkout until you say to post. A checker agent rechecks each finding in a fresh context. Skill descriptions send a request to address comments on your own PR to `build`: `review`'s says it answers replies to your review comments, on PRs you reviewed. `build` runs a local review of its own uncommitted changes through `review`, after writing its plan's specs into `docs/specs/`.

## Scope

In: specs in the review's context; spec mismatches as blocking findings; the README's `review` section.
Out: reviewing a spec on its own; specs whose area the diff doesn't touch; how the review checker treats findings (the review-checker spec); moving back an archived review file; checking a PR's author to send comments on your own PR to `build`.

## Behaviour

```gherkin
Scenario: A PR that contradicts a spec is blocked
  Given docs/specs/auth.md says sessions last 1 hour
  And a PR makes sessions last 24 hours without changing auth.md
  When you review the PR
  Then a blocking finding asks: "auth.md says sessions last 1 hour. Should it say 24 now, or should this stay at 1?"

Scenario: Work a later PR of the plan will do isn't flagged
  Given auth.md already says 24 hours, and the PR's merge order names the later PR that makes it so
  And this PR keeps sessions at 1 hour
  When you review the PR
  Then there is no finding about the session length

Scenario: A spec updated with the code is fine
  Given a PR makes sessions last 24 hours and changes auth.md to say 24 hours
  When you review the PR
  Then there is no finding about auth.md

Scenario: Build's own reviews check specs too
  Given build's uncommitted changes contradict docs/specs/auth.md
  When build reviews them before you commit
  Then the review finds the same blocking mismatch
```

## Design

Related repos come from the main checkout's `CLAUDE.md` and `CLAUDE.local.md`, through the shared `related-repos.sh`, wherever `review` runs.

The context step gathers the specs in `docs/specs/` that share the diff's area, found by searching them for the diff's key terms (skill and feature names, behaviours, settings, paths), read from the PR's worktree, or from the checkout for a local review.

A finding is blocking for broken behaviour, security, breakage elsewhere, or code that no longer matches a part of a spec (a scenario or a Decision) the PR didn't update. A spec mismatch asks which should change, the code or the spec, citing the spec's line. A mismatch that a later task or PR of the same plan will close isn't a finding, when the later tasks and MRs `build` names in asking for the local review, or the PR's merge order, include that later work.

The README's `review` section says it holds PRs to the repo's specs, with no sentence about handing your own PR's comments to `build` or moving archived files back.

Testing: the repo's check script and markdownlint, and a review of a sample PR that contradicts a spec.

## Decisions

- **Every spec mismatch is blocking, asked as a question**: Why: specs must always match the code, and either fix is small. Not non-blocking for improvements: a stale spec misleads the next plan just the same.
- **Either fix clears it, with no reason required**: Why: what matters is that code and spec agree. Not demanding the PR explain every spec edit.
- **No hand-off line for comments on your own PR**: Why: with `review`'s description narrowed to replies on your own review comments, the descriptions send them to `build`. Not a check in `review` that reads your login to route them.
- **Review files stay in `.ai/reviews/`**: Why: nothing archives them any more (`daily` doesn't), so there's nothing to move back. Not moving files out of `completed/`.
- **Specs found by area, not path**: Why: specs aren't indexed by the files they cover. Not a path index every spec would have to keep up.
