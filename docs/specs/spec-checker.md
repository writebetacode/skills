# Spec checker

Before `plan` walks you through a spec, a fresh agent checks it against the spec rules, the repo's own rules and every other spec it touches, so a missing piece, something that doesn't belong, or a clash with an earlier decision turns up before you approve the spec, not when `build` runs into it.

## Context

`plan` writes each spec its change touches in its plan folder, then walks them with you. The spec rules say a spec stands alone, links to nothing, holds no code or ticket keys, keeps only what matters, and describes behaviour in scenarios, never how a test is built. Committed specs live in `docs/specs/`; a plan's specs stay in its gitignored plan folder, which searches skip, until `build` commits them.

## Scope

In: the `spec-checker` agent; `plan` running it on each new, edited or revised spec before the walk.
Out: checking tasks; checking specs written outside `plan`; epics (reading every unbuilt feature's specs; treating an earlier feature's draft with the same file name as landing first, so not a clash).

## Behaviour

```gherkin
Scenario: A clash with another spec
  Given docs/specs/auth.md decided sessions last 1 hour
  And the draft says sessions last 24 hours without editing auth.md
  When plan checks the draft
  Then the checker flags the clash, citing both specs

Scenario: Something missing
  Given the draft's scope includes exporting to CSV, but no scenario or design covers it
  When plan checks the draft
  Then the checker flags exporting to CSV as missing

Scenario: Something that doesn't belong
  Given the draft links to a ticket and holds a code snippet
  When plan checks the draft
  Then the checker flags both, citing the spec rules

Scenario: Plan fixes, then asks you about the rest
  Given the checker returned findings
  When plan has fixed the ones it agrees with and rerun the checker, at most twice
  Then any finding still open, or one plan disagrees with, is an open question in the walk
```

## Design

`agents/spec-checker.md`, read-only, using the session's model. `plan` calls it as that agent type, once per spec, with only paths: that spec, the spec rules file, the root of the repo the spec ships in and its `docs/specs/`, and the plan's other specs, which it reads whole. A `docs/specs/` spec with the file name of this spec or another of the plan's specs is that spec's old version, being replaced: no clash.

It checks each spec against the spec rules, the repo's instruction files (`CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`) at its root and nearest each path the spec names, every other spec touching the same behaviours or terms (a contradiction, the same thing specified twice, a term used differently), and whether it can be built alone (an in-scope item with no scenario or design, an undefined term, a blocking open question). It replies with a verdict (ready, or gaps) and a numbered list, each finding naming its kind (missing, doesn't belong, clash, unclear), the section, the problem, its source and a fix.

Testing: the repo's check script and markdownlint, and running the checker on a spec with a planted clash and a planted link.

## Decisions

- **A separate agent in a fresh context, given only paths**: Why: a spec's writer reads what they meant, and a checker that saw the conversation would fill the gaps without noticing them. Not a self-check inside `plan`.
- **Once per spec, with the plan's other specs in view**: Why: each spec gets a focused read, and clashes between a plan's own specs still show. Not one run over all of them.
- **At most two reruns, then open questions**: Why: it stops a loop, and what's left is for you to decide. Not blocking until clean.
- **Read-only, using the session's model**: Why: it judges and never edits. Not a smaller model: it misses clashes between specs.
