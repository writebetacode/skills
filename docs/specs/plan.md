# Plan

`plan` turns a request into specs, tickets and tasks you approve before code exists, so `build` never has to guess.

## Why

Code written before you agree on what to build gets rewritten. The next change needs each area's what and why in one place, readable in minutes.

## What

`plan` talks a request through with you, has `research` find what it needs, and writes a plan folder for `build`, shared by every worktree. A separate spec checker reads it before you do.

## Behaviour

- It agrees on the request with you, one question at a time. A bug goes to `research` first.
- Each area the change touches, or whose spec it makes untrue, gets one spec: the file specifying that area today, whatever its name.
- A new area's spec goes in the folder with the most specs, named like them, else `docs/specs/`.
- A spec is a short white paper of what the area does, why, and how it behaves, in `voice`'s plain words. Older ones get rewritten that way when they next change.
- After the spec checker, `plan` walks you through each spec's decisions and open questions, approving it only when you say so.
- Each MR gets a ticket (what, why, acceptance criteria) and tasks, one commit each, holding the how. Each criterion sits under one task.
- Criteria come only from what the specs change (a removal only when Out of scope names it), never from rewording or slimming.
- Tickets follow `ticket`'s templates, or your tracker's recent ones, in `voice`'s words too, filed only when you ask.
- An upgrade the change needs gets its own task first, or its own MR if its breaking changes reach untouched code.
- Speccing an area as it is writes what it does now and why, without criteria.
- Splitting a branch plans pieces that each ship alone, carrying its code. The branch is never touched.
- A revision restarts each spec it touches from the base's latest version, keeping the plan's changes, and rewrites only uncommitted tasks.
- A plan with tasks but no tickets gets tickets on revision.

## Decisions

- **One living spec per area, in the repo's own spec folder**: Why: one place per area, kept true by every change. A second home beside the repo's own, like `docs/superpowers/specs/`, would split an area.
- **White-paper specs**: Why: read in minutes, a spec stays the 10,000-foot view. Not scenarios: they made specs test lists.
- **Tickets between specs and tasks**: Why: each MR gets its own what, why and criteria, which a reviewer follows commit by commit.
- **Specs stay in the plan folder until `build` commits them**: Why: a build in another worktree sees the plan folder, not your branch.
- **A change to a ticket or spec goes back through `plan`**: Why: they're what you approved and the checker read.
- **Upgrades are tasks, never specs**, even when the whole request is one. A split's bump is redone, not carried over. Why: a spec holds whatever versions you pick, and lockfile changes rarely apply once the base moves.
- **Fixed criteria where no test can fail**, like `specs ship (docs only: no new test)`, so specs can ship alone. Why: `build` must know when no failing test is possible, and commits specs only with a task.
- **No epics**: Why: a plan per feature does the same with one less layer.

## Out of scope

- Investigating bugs; how `build` commits specs and carries a split's code.
- An upgrade that fits one PR: `build` takes it.
