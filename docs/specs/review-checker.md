# Review checker

The review checker rechecks each drafted review finding in a fresh context, stricter than the reviewer was, so only findings that hold up reach you. It keeps a finding about code that no longer matches the repo's specs blocking, since specs must always match the code.

## Context

`review` drafts findings on a PR or on local changes it reviews itself; `build` gets findings from the local review it asks for. Each hands the checker the findings, the diff, the code, and any spec, ticket, task, findings file or request the change was reviewed against, and nothing of the conversation behind them. `daily`'s re-reviews run `review`, so they reach the checker through it. The checker judges and changes nothing.

## Scope

In: the review checker: what it keeps, downgrades and withdraws, its reply, and who calls it.
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
  Then it downgrades the finding to non-blocking, since only broken behaviour, security, breakage elsewhere or a spec mismatch the change didn't update stays blocking

Scenario Outline: A finding that doesn't hold is withdrawn
  Given review drafted a finding <problem>
  When the checker rechecks it against the code, and against what was asked where the finding rests on it
  Then it withdraws the finding, and review never writes it

  Examples:
    | problem                                              |
    | about a problem the code already had before the change |
    | citing code that isn't there                         |
    | whose claim doesn't hold                             |
    | that doesn't matter                                  |
    | that repeats another finding                         |
    | that's a preference                                  |
    | that a linter rule already covers                    |

Scenario: A wrong example is fixed, not the finding
  Given a finding holds, but its example of the fix is wrong
  When the checker rechecks it
  Then it fixes or drops the example and keeps the finding

Scenario: Its reply
  Given the checker rechecked three findings
  When it replies
  Then it gives one line per finding, in order, saying kept, downgraded or withdrawn and why in a few words
  And then the kept findings word for word, apart from downgrades and fixed examples
  And it adds no findings of its own
```

## Decisions

- **Spec mismatches are part of the blocking bar**: Why: `review` blocks them, and a checker with an older bar would quietly undo that.
- **Only `review` and `build` call it**: Why: `daily` reaches it only through `review`. Not a direct call from `daily`, or from every skill whose work it touches.
- **Its result is final**: Why: a reviewer who argues with the checker brings back the bias it was there to remove. Not a second round with the reviewer.
