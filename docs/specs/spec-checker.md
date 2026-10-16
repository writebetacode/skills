# Spec checker

Before `plan` walks you through a spec, a fresh agent checks it against the spec rules, the repo's own rules and every other spec it touches. A missing piece, something that doesn't belong, or a clash with an earlier decision then turns up before you approve the spec, not when `build` runs into it.

## Context

`plan` writes each spec its change touches, new or edited, in its plan folder, then walks them with you. The spec rules say a spec must stand alone for someone who never saw the conversation, link to nothing and hold no code or ticket keys, keep every decision in Decisions with its reason and the alternative turned down, and describe behaviour in scenarios, never how a test is built. Committed specs live in `docs/specs/`, one living spec per domain area, with no sub-folders; a plan's specs, approved or not, stay in its plan folder until `build` commits them. That folder is gitignored, so searches skip it.

Two other checker agents exist. `review`'s rechecks review findings, and its result is final. `plan`'s debug checker challenges a debugging conclusion, and `plan` reruns it at most twice. Each runs in a fresh context with read-only tools, gets only file paths, and replies in a fixed format.

## Scope

In: the `spec-checker` agent; `plan` running it on each new or edited spec, and on revised specs, before the walk.
Out: checking tasks or upgrade lists; checking specs written outside `plan`.

## Behaviour

```gherkin
Scenario: A clash with an earlier spec
  Given docs/specs/auth.md decided sessions last 1 hour
  And the draft says sessions last 24 hours without editing auth.md
  When plan checks the draft
  Then the checker flags the clash, citing both specs

Scenario: A clash with another spec in the same plan
  Given a plan drafts review.md and edits daily.md
  And the two disagree about who re-reviews a PR
  When plan checks each
  Then the checker flags the clash, citing both

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

`agents/spec-checker.md`, read-only (it can read and search files, nothing else), using the session's model. `plan` calls it as that agent type, never a fork or another type, once per new or edited spec, with only paths: that spec, the spec rules file, the root of the repo the spec ships in and that checkout's `docs/specs/`, and the path of each of the plan's other specs, which it reads whole since searches skip the plan folder. In an epic, those are the specs of every feature not yet built, siblings included. The checkout's `docs/specs/` may lag the base the plan copied from; `build`'s check for changed specs covers that before anything is written. A `docs/specs/` spec with the same name as one in the plan is that spec's old version: it's being replaced, so it's no clash. It never sees the conversation or research, so it reads the spec the way a later reader will.

It checks the spec for:

- **Spec rules**: each rule in the rules file, including that the spec stands alone.
- **Repo rules**: the instruction files at the repo root and nearest to each path the spec names (`CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`), wherever the spec's design or behaviour would break one.
- **Other specs**: every other spec, in `docs/specs/` or this plan, that touches the same behaviours, terms or components (found by its key terms), for a behaviour or decision the spec contradicts, the same thing specified twice, or a term used differently. A spec this plan already edited to agree is no clash.
- **Buildable alone**: an in-scope item with no scenario or design, a term never defined, or an open question that would block building.

It replies with a verdict (ready, or gaps) and a numbered list. Each finding names its kind (missing, doesn't belong, clash, unclear), the spec section, the problem in a sentence, where it comes from (the rule, or the other spec's path and line) and a suggested fix.

In `plan`, after the specs are written and before the walk: run the checker on each; fix each finding `plan` agrees with and rerun, at most twice; anything left, or disputed, becomes an open question in that spec's Questions and is raised in the walk. A revision runs the same check on each changed spec before walking the changes.

The README's `plan` section says a checker looks over each spec before you see it.

Testing: the repo's check script (budgets, links, the agent named by a skill) and markdownlint, and running the checker on one of the specs in `docs/specs/` with a planted clash and a planted link, and on a plan whose two specs clash.

## Decisions

- **A separate agent in a fresh context**: Why: the writer of a spec reads what they meant, not what they wrote; the other checkers work this way. Not a self-check inside `plan`.
- **Paths only, no conversation or research**: Why: the spec must stand alone; a checker that saw the conversation would fill the gaps without noticing them. Not passing the research.
- **Once per spec, with the plan's other specs in view**: Why: each spec gets a full, focused read, and clashes between a plan's own specs still show. Not one run over all of them: a long plan would get a shallow read.
- **Before the walk, and on revisions**: Why: you should only see a spec that's already been checked. Not after approval: too late to be cheap.
- **At most two reruns, then open questions**: Why: like the debug checker, it stops a loop, and what's left is for you to decide. Not blocking until clean.
- **Read-only, using the session's model**: Why: it judges and never edits; the session's model already handles `plan`. Not a smaller model: it misses clashes between specs.
