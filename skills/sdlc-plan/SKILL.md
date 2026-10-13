---
name: sdlc-plan
description: Plan a feature, bug fix, research request, epic or ticket into `.ai/sdlc/<name>/`: a self-contained spec agreed with the user, then commit-sized tasks grouped into merge requests. Use when asked to plan, spec or scope work before building it, to turn a ticket into a plan, or when sdlc-build hands back a change to an approved spec.
---

Folder: `<git rev-parse --show-toplevel>/.ai/sdlc/<name>/`, `<name>` 2–4 kebab-case words, not already under `.ai/sdlc/`. `git check-ignore` fails on it → append `*` to `.ai/.gitignore`.

```
spec.md              human-readable source of truth
status.md            ticket, progress
research/<topic>.md  one research report each
tasks/NN-<mr>.md     one per MR; NN = merge order
```

Epic (several features that each ship alone): its own `spec.md` and `status.md`, plus `NN-<feature>/` sub-folders in build order, each laid out as above.

Talk to the user only in `same-page` rounds (the request, then each open choice the spec needs), the spec walk and the final reply. Never ask them to approve research.

## Plan

1. Ticket key or URL → `ticket` skill: view. Input only.
2. `same-page` on the request. Several features that each ship alone → propose an epic in that round.
3. Research quietly: `research` skill per thing the spec needs (how it works here, patterns to follow, versions in use, other repos touched); save each report as `research/<topic>.md`.
4. Invoke the `voice` skill; write `spec.md`.
5. Walk it: path, then its decisions and open questions in ≤8 lines; ask to approve or change. Changes → `same-page` on them, edit, walk again; open questions → settle before approval. Explicit approval only → `status.md` `spec: approved <date>`.
6. Tasks from `spec.md` alone: never research, tickets or this conversation.
7. Reply: folder path; MRs in order with repo, branch, task count; next step: `sdlc-build`. Nothing to build → say `sdlc-build` closes it.

Tickets: file or link only when asked (`ticket` skill); record in `status.md`, never `spec.md`.

## Revise

An existing folder, or `sdlc-build` handing back a change → `same-page` on the change; invoke the `voice` skill; edit `spec.md`, adding the decision; walk the changed parts. On approval rewrite only uncommitted tasks; committed ones stay byte-for-byte; one the change contradicts → a new task reversing it.

## spec.md

Written for someone who saw none of the conversation, tickets or research: restate everything they need. No code, ticket keys or research references. Omit sections with nothing to say. Research request → the question, the answer and why; Behaviour and Design only for a deliverable it asks for.

````
# <Title>

<2–3 sentences: what changes, for whom, why.>

## Context
<Today's behaviour; the code, repos and constraints involved.>

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

- Scenarios state behaviour, never test construction: ✗ `Given UserRepo is mocked` ✓ `Given no account for that email`. Several cases → `Scenario Outline` + `Examples`.
- Epic `spec.md`: Design lists its features in build order, one line each.

## tasks/NN-\<mr\>.md

Terse, for an agent. MR = one branch that works and ships alone; MRs merge strictly in NN order, never in parallel. One repo per MR; work spanning repos → one MR per repo, each naming the others in `with:`.

```
# <NN>: <MR title>
repo: <name> <local path>
branch: <type>/<ticket>-<short-name>
base: <branch>
after: <NN | none>
with: <NN, … | none>

## 1. <task: one commit>
<what changes, in spec terms; code areas>
- [ ] <spec scenario name | observable check when no scenario fits>
```

- `base:` an earlier MR's branch only when this MR needs its code (stacked); else that repo's default branch, found as the `branch` skill finds it.
- Branch named per the `branch` skill, lowercase, ticket from `status.md`: ✓ `feat/abc-77-login-lockout`.
- Each spec scenario is an AC of exactly one task. Each task carries its own tests: never a tests-only or code-only task.
- Another repo's path: `## Related repos` in loaded `CLAUDE.md`, else a sibling folder of that name; else ask.

## status.md

```
ticket: <key | URL | none>
spec: <draft | approved YYYY-MM-DD>

## MRs
- NN-<mr>: <todo | building | committed | open <url> | merged>
```

Epic: `## Features` instead, `- NN-<feature>: <todo | building | done>`.
