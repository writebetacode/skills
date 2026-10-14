# Spec checker

Before `plan` walks you through a draft spec, a fresh agent now checks it against the spec rules, the repo's own rules and the specs already committed. It catches a missing piece, something that doesn't belong, or a clash with an earlier decision before you approve it, instead of when `build` runs into it. Debugging conclusions and review findings already get a checker like this; specs, which everything after them is built from, don't.

## Context

`plan` writes a spec from the conversation and its research, then walks it with you. The spec format has rules: it must stand alone for someone who never saw the conversation, it links to nothing and holds no code or ticket keys, every decision lives in Decisions with its reason and the alternative turned down, and scenarios describe behaviour, never how a test is built. Approved specs live in `docs/specs/`; when a new spec makes an older one untrue, `plan` edits the older one to match.

Two checker agents already exist: one rechecks review findings and one challenges a debugging conclusion. Each runs in a fresh context with read-only tools, gets only file paths, and replies in a fixed format; the calling skill reruns it at most twice.

## Scope

In: a `spec-checker` agent; `plan` running it on each draft spec and on revised specs before the walk; marking it Done in `docs/proposed-improvements.md`; the README.
Out: checking tasks or upgrade lists; checking specs written outside `plan`.

## Behaviour

```gherkin
Scenario: A clash with an earlier spec
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

Scenario: A repo rule
  Given the repo's AGENTS.md says skills write only under .ai/
  And the draft has a skill write into .claude/
  When plan checks the draft
  Then the checker flags it, citing that rule

Scenario: Plan fixes, then asks you about the rest
  Given the checker returned findings
  When plan has fixed the ones it agrees with and rerun the checker, at most twice
  Then any finding still open, or one plan disagrees with, is an open question in the walk

Scenario: A clean spec
  Given a draft that follows every rule and clashes with nothing
  When plan checks it
  Then the checker says it's ready and the walk starts with no extra questions

Scenario: Revisions get checked too
  When plan revises an approved spec
  Then the changed spec goes through the checker before the changed parts are walked
```

## Design

`agents/spec-checker.md`, read-only (it can read and search files, nothing else), using the session's model. `plan` calls it as that agent type, never a fork or another type, with only paths: the draft spec, the spec rules file, the repo root and the specs folder. It never sees the conversation or research, so it reads the spec the way a later reader will.

It checks the draft for:

- **Spec rules**: each rule in the rules file, including that the spec stands alone.
- **Repo rules**: the instruction files at the repo root and nearest to each path the spec names (`CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`), wherever the spec's design or behaviour would break one.
- **Earlier specs**: every committed spec that shares its subject, for a behaviour or decision the draft contradicts, the same thing specified twice, or a term used differently.
- **Buildable alone**: an in-scope item with no scenario or design, a term never defined, or an open question that would block building.

It replies with a verdict (ready, or gaps) and a numbered list. Each finding names its kind (missing, doesn't belong, clash, unclear), the spec section, the problem in a sentence, where it comes from (the rule, or the other spec's path and line) and a suggested fix.

In `plan`, after the spec is written and before the walk: run the checker; fix each finding `plan` agrees with and rerun, at most twice; anything left, or disputed, becomes an open question in the spec's Questions and is raised in the walk. A revision runs the same check on the changed spec before walking the changes.

The README's `plan` section says a checker looks over each spec before you see it.

Testing: the repo's check script (budgets, links, the agent named by a skill), and running the checker on one of the specs from this epic with a planted clash and a planted link.

## Decisions

- **A separate agent in a fresh context**: Why: the writer of a spec reads what they meant, not what they wrote; the other checkers work this way. Not a self-check inside `plan`.
- **Paths only, no conversation or research**: Why: the spec must stand alone; a checker that saw the conversation would fill the gaps without noticing them. Not passing the research.
- **Before the walk, and on revisions**: Why: you should only see a spec that's already been checked. Not after approval: too late to be cheap.
- **At most two reruns, then open questions**: Why: it matches the other checkers and stops a loop; what's left is for you to decide. Not blocking until clean.
- **Read-only, using the session's model**: Why: it judges and never edits; the session's model already handles `plan`. Not a smaller model: it misses clashes between specs.

## Questions

None.
