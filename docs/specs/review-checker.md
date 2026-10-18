# Review checker

The review checker rechecks each drafted review finding in a fresh context, stricter than the reviewer was, so only findings that hold up reach you. It keeps a finding about code that no longer matches the repo's specs blocking, since specs must always match the code.

## Context

`review` drafts findings on a PR or on local changes it reviews itself; `build` gets findings from the local review it asks for in a subagent. Each hands the checker only paths: the findings, the diff, the code, and any spec, ticket, task, findings file or request the change was reviewed against. `daily`'s re-reviews run `review`, so they reach the checker through it.

## Scope

In: the `review-checker` agent: what it keeps, downgrades and withdraws, its reply, and who calls it.
Out: how `review` drafts findings and finds spec mismatches (the review spec).

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

Scenario: A finding that doesn't hold is withdrawn
  Given review drafted a finding about a problem the code already had before the change
  When the checker rechecks it
  Then it withdraws the finding, and review never writes it
```

## Design

`agents/review-checker.md`, read-only, using the session's model, for `review` and `build`. It re-derives each finding from the code, and from the spec, ticket, task, findings file or request where the finding rests on what was asked. It keeps a finding only if the cited code is there, the claim holds, it traces to this change, it matters, and it isn't a duplicate, a preference or a linter rule. A blocking finding outside the bar (broken behaviour, security, breakage elsewhere, or code that no longer matches a part of a spec (a scenario or a Decision) the change didn't update) becomes non-blocking. A wrong example gets fixed or dropped, never the finding. It never adds findings, and its result is final.

It replies with one line per finding, in order (kept, downgraded or withdrawn, with why in a few words), then the kept findings word for word, apart from downgrades and fixed examples.

Testing: the repo's check script and markdownlint; a review of a sample PR that contradicts a spec.

## Decisions

- **Spec mismatches are part of the blocking bar**: Why: `review` blocks them, and a checker with an older bar would quietly undo that.
- **Its description names only the skills that call it**: Why: `daily` reaches it only through `review`, so naming `daily` would invite a direct call. Not listing every skill whose work it touches.
- **Its result is final**: Why: a reviewer who argues with the checker brings back the bias it was there to remove. Not a second round with the reviewer.
