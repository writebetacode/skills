# Spec checker

Before `plan` shows you a plan, a fresh agent reads all of it first. A gap, a clash or a task that adds a second way to do something then turns up before you approve it, not when `build` runs into it.

## Why

A plan's writer reads what they meant and fills its gaps without noticing. Anything missed costs more later: a spec clash found in review, criteria no task meets, or a task rebuilding a helper the repo already has.

## What

`plan` runs the checker after writing specs, and again after writing tickets and tasks. By then you've approved the specs, so the second run checks only tickets and tasks. It gets the plan folder, the rules for each kind of file, and each repo the plan touches with its spec folders and related repos. It reports and changes nothing.

## Behaviour

- It flags a spec that breaks the spec rules: anything past a short white paper of what, why and behaviour doesn't belong, like how it's built or acceptance criteria.
- It flags a spec or task that breaks a rule in the repo's `CLAUDE.md`, `AGENTS.md` or `CONTRIBUTING.md`, citing the rule.
- It flags a clash, citing both, when a spec contradicts another spec or draft, specifies the same thing twice, or uses a term differently. The file a draft replaces is its old version, not a clash.
- It flags as missing anything in scope that nothing describes, a term never defined, or an open question that would block building.
- It flags a ticket that says how, a criterion that traces to no spec behaviour and isn't one of the fixed ones, and a spec change that should have a criterion but has none.
- It flags a ticket criterion under no task, or under more than one.
- It searches the code and related repos past the paths tasks name, and flags a task that adds what already exists (reuse) or builds on a way the repo is moving away from (pattern).
- It flags only what it can cite, never style or wording.
- `plan` fixes the findings it agrees with and reruns it at most twice. Whatever's left comes to you as open questions.

## Sketch

```text
Verdict: ready | gaps
1. <missing | doesn't belong | clash | unclear | reuse | pattern>: <file> <section>: <problem> [<rule, or path:line>] → <fix>
```

## Decisions

- **A separate check that sees none of the conversation**: Why: a checker that saw it would fill the gaps without noticing them. Not a self-check inside `plan`.
- **The whole plan at once**: Why: criteria trace to specs and tasks to criteria, and clashes between a plan's own specs show up in one read. Not once per spec: tickets and tasks span specs.
- **Two runs, the second skipping approved specs**: Why: tickets are written against settled specs, and the second run doesn't reopen what you approved.
- **It searches past the paths tasks name**: Why: tasks shouldn't add a second way to do something, and what they'd duplicate lives outside the files they name.
- **At most two reruns, then open questions**: Why: it stops a loop, and what's left is yours to decide. Not blocking until it's clean.
- **It only reports**: Why: it judges and never edits.

## Out of scope

- Specs written outside `plan`: `review` holds those to the spec rules when a PR adds or changes them.
- Other plans' drafts: it doesn't read them or know which lands first.
