# Review checker

The review checker rechecks each drafted review finding in a fresh context, stricter than the reviewer was, so only findings that hold up reach you. It keeps a finding about code that no longer matches the repo's specs blocking, since specs must always match the code.

## Context

`review` drafts findings on a PR, or on `build`'s uncommitted changes, and hands the checker only paths: the findings, the diff, the code, and any spec or ticket. The checker re-derives each finding, keeps it only if it holds and matters, and never adds findings; its result is final. A finding is blocking for broken behaviour, security or breakage elsewhere, and for code that no longer matches a part of a spec (a scenario, Design text or a Decision) the change didn't update.

## Scope

In: the downgrade rule for blocking findings.
Out: how `review` finds spec mismatches (the review spec); everything else the checker does, until a change touches it.

## Behaviour

```gherkin
Scenario: A spec mismatch stays blocking
  Given review drafted a blocking finding that a PR makes sessions last 24 hours while docs/specs/auth.md says 1 hour
  When the checker rechecks it and the claim holds
  Then it keeps the finding blocking

Scenario: Other blocking findings outside the bar are downgraded
  Given review drafted a blocking finding that an edge case has no test
  When the checker rechecks it
  Then it downgrades the finding to non-blocking
```

## Design

The checker's downgrade rule keeps blocking for broken behaviour, security, breakage elsewhere, and code that no longer matches a part of a spec (a scenario, Design text or a Decision) the change didn't update; anything else marked blocking becomes non-blocking. `build`, which passes its own review's findings to the checker, needs no change.

Testing: the repo's check script and markdownlint; a review of a sample PR that contradicts a spec.

## Decisions

- **Spec mismatches are part of the blocking bar**: Why: `review` blocks them, and a checker using an older bar would quietly undo that. Not leaving the rule to `review` alone.
