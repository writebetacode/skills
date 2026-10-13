---
name: plan
description: Plan work into a spec and tasks, or prove why something's broken. Use when asked to plan, spec or scope work; to debug a bug, error, failing test, incident or alert; or to write up findings or a postmortem.
---

Folder: `<git rev-parse --show-toplevel>/.ai/plan/<name>/` (no repo → `./.ai/plan/<name>/`), `<name>` 2–4 kebab-case words, not already under `.ai/plan/`. `git check-ignore` fails on it → append `*` to `.ai/.gitignore`.

```
spec.md              draft; approved with something to build → docs/specs/<name>.md
status.md            ticket, spec, progress
findings.md          a bug's proven cause (investigate.md)
research/<topic>.md  one report each
tasks/NN-<mr>.md     one per MR; NN = merge order
```

Epic (several features that each ship alone): its own `spec.md` and `status.md`, plus `NN-<feature>/` sub-folders in build order, each laid out as above.

Talk to the user only in `same-page` rounds (the request, then each open choice the spec needs), the spec walk and the final reply. Never ask them to approve research. Write only this folder and specs; outside investigate.md, run no experiments.

## Plan

1. Inputs only, nothing else before `same-page`: ticket key or URL → `ticket` skill: view; `.ai/plan/<name>/findings.md` given → read it (its `research/` counts as step 3's: reuse, don't redo).
2. `same-page` on the request. Something broken to track down (bug, error, failing test, incident, alert) → read [investigate.md](investigate.md); come back only to plan its fix. Several features that each ship alone → propose an epic in that round.
3. Research quietly: `research` skill per thing the spec needs (how it works here, patterns to follow, versions in use, other repos touched, specs in `docs/specs/` it touches); save each report as `research/<topic>.md`.
4. Invoke the `voice` skill (once per session); write `spec.md`. Each `docs/specs/` spec this change makes untrue → edit it to match, adding a Decision: what changed, why.
5. Walk it: path, then its decisions and open questions in ≤8 lines; ask to approve or change. Changes → `same-page` on them, edit, walk again; open questions → settle before approval. Explicit approval only → something to build: move the spec to `docs/specs/<name>.md` (epic feature: `docs/specs/<epic>/<feature>.md`, no `NN-`); `status.md` `spec: approved <date> <spec path>`, then each edited spec's path.
6. Tasks: read [tasks.md](tasks.md).
7. Reply: folder and spec paths; MRs in order with repo, branch, task count; next step: `build`. Nothing to build → say `build` closes it.

Tickets: file or link only when asked (`ticket` skill); record in `status.md`, never the spec.

## Revise

An existing folder, or `build` handing back a change → `same-page` on the change; invoke the `voice` skill (once per session); edit the spec (and specs it makes untrue), adding the decision; walk the changed parts. On approval rewrite only uncommitted tasks, per tasks.md; committed ones stay byte-for-byte; one the change contradicts → a new task reversing it.

## The spec

For readers who'll never see the conversation, tickets, findings or research: the complete what and why, enough to build it from alone. Links to nothing; no code or ticket keys. Omit sections with nothing to say. Research request → the question, the answer and why; Behaviour and Design only for a deliverable it asks for.

````
# <Title>

<2–3 sentences: what changes, for whom, why.>

## Context
<Today's behaviour; the code, repos and constraints involved; a bug's proven cause.>

## Scope
In: <…>
Out: <…>

## Behaviour
```gherkin
Scenario: <observable outcome>
  Given <state>
  When <action>
  Then <what a user or caller sees>
```

## Design
<How it works: components and where they live, interfaces and data in words, errors, how it's tested, repos touched and which ships first.>

## Decisions
- **<Topic>**: <decision>. Why: <reason>. Not <alternative>: <why>.

## Questions
- <question raised along the way> → <answer | Open: <assumption>>
````

- Decisions: every one made along the way, here and nowhere else.
- Scenarios state behaviour, never test construction: ✗ `Given UserRepo is mocked` ✓ `Given no account for that email`. Several cases → `Scenario Outline` + `Examples`.
- Epic spec: Design lists its features in build order, one line each.

## status.md

```
ticket: <key | URL | none>
spec: <draft | approved YYYY-MM-DD <spec path>[, <edited spec path>…]>

## MRs
- NN-<mr>: <todo | building | committed | open <url> | merged>
```

Epic: `## Features` instead, `- NN-<feature>: <todo | building | done>`.
