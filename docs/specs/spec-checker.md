# Spec checker

Before `plan` walks you through a spec, a fresh agent checks it against the spec rules, the repo's own rules and every other spec it touches, so a missing piece, something that doesn't belong, or a clash with an earlier decision turns up before you approve the spec, not when `build` runs into it.

## Context

`plan` writes each spec its change touches in its plan folder, then walks them with you. The spec rules say a spec covers what its area does and why but not how it's built, stands alone, links to nothing, holds no code or ticket keys, keeps only what matters, and describes behaviour in scenarios, never how a test is built. Committed specs live in `docs/specs/`; a plan's specs stay in its gitignored plan folder, which searches skip, until `build` commits them. For each spec, `plan` gives the checker that spec, the spec rules, the repo the spec ships in with its `docs/specs/`, and the plan's other specs, which it reads whole. The checker judges and changes nothing.

## Scope

In: the spec checker; `plan` running it on each new, edited or revised spec before the walk.
Out: checking tasks; checking specs written outside `plan`; epics (reading every unbuilt feature's specs; treating an earlier feature's draft with the same file name as landing first, so not a clash).

## Behaviour

```gherkin
Scenario Outline: A clash with another spec
  Given docs/specs/auth.md decided sessions last 1 hour
  And <draft>
  When plan checks the draft
  Then the checker flags the clash, citing both specs

  Examples:
    | draft                                                          |
    | the draft says sessions last 24 hours without editing auth.md  |
    | the draft specifies session length again, the same as auth.md  |
    | the draft uses "session" for something auth.md doesn't         |

Scenario: A spec's old version is no clash
  Given docs/specs/auth.md says sessions last 1 hour
  And the plan's specs/auth.md changes that to 24 hours
  When plan checks the draft
  Then the checker treats docs/specs/auth.md as the old version being replaced, and flags no clash

Scenario: Breaking the repo's rules
  Given the repo's AGENTS.md says every endpoint needs an audit log
  And the draft adds an endpoint that writes none
  When plan checks the draft
  Then the checker flags it, citing AGENTS.md
  And it reads CLAUDE.md, AGENTS.md and CONTRIBUTING.md at the repo's root and nearest each path the draft names

Scenario Outline: Something missing
  Given <gap>
  When plan checks the draft
  Then the checker flags <what> as missing

  Examples:
    | gap                                                                   | what                  |
    | the draft's scope includes exporting to CSV, but nothing in it describes the export | exporting to CSV |
    | the draft uses "grace period" and never says what it is               | "grace period"        |
    | an open question decides whether export runs nightly or on demand     | that question         |

Scenario: Something that doesn't belong
  Given the draft links to a ticket, holds a code snippet and names the class that stores lockouts
  When plan checks the draft
  Then the checker flags all three, citing the spec rules

Scenario: Its reply
  When the checker is done with a draft
  Then it replies ready, or gaps with a numbered list
  And each finding names its kind (missing, doesn't belong, clash, unclear), the section, the problem, its source and a fix

Scenario: Plan fixes, then asks you about the rest
  Given the checker returned findings
  When plan has fixed the ones it agrees with and rerun the checker, at most twice
  Then any finding still open, or one plan disagrees with, is an open question in the walk
```

## Decisions

- **A separate check that sees none of the conversation**: Why: a spec's writer reads what they meant, and a checker that saw the conversation would fill the gaps without noticing them. Not a self-check inside `plan`.
- **Once per spec, with the plan's other specs in view**: Why: each spec gets a focused read, and clashes between a plan's own specs still show. Not one run over all of them.
- **At most two reruns, then open questions**: Why: it stops a loop, and what's left is for you to decide. Not blocking until clean.
- **It only reports**: Why: it judges and never edits.
