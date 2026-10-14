---
name: plan
description: Plan work, answer questions or prove why something's broken. Use when asked to plan, spec or scope work; to look into how something works here, which pattern to follow or versions in use; to debug a bug, error, failing test, incident or alert; or to write up findings or a postmortem.
---

Just a question to answer (how something works here, which pattern to follow, versions in use) → follow only [research.md](research.md). A change to an existing plan, asked or handed back by `build` → read [revise.md](revise.md). A plan at `upgrades: draft` → resume step 6's walk; then `tasks/` exists → revise.md's task rewrite, else step 7.

Folder: `<git rev-parse --show-toplevel>/.ai/plan/<name>/` (no repo → `./.ai/plan/<name>/`), `<name>` 2–4 kebab-case words, not already under `.ai/plan/` or `docs/specs/`. `git check-ignore` fails on it → append `*` to `.ai/.gitignore`.

```
spec.md              draft; approved with something to build → docs/specs/<name>.md
status.md            ticket, spec, progress
findings.md          a bug's proven cause (investigate.md)
upgrades.md          dependency upgrades the feature needs (step 6)
research/<topic>.md  one report each
tasks/NN-<mr>.md     one per MR; NN = merge order
```

Epic (several features that each ship alone): its own `spec.md` and `status.md`, plus `NN-<feature>/` sub-folders in build order, each laid out as above.

Talk to the user only in `same-page` rounds (the request, then each open choice the spec needs), the spec and upgrade walks, and the final reply. Never ask them to approve research. Write only this folder and specs; outside investigate.md, run no experiments.

## Plan

1. Inputs only, nothing else before `same-page`: ticket key or URL → `ticket` skill: view; `.ai/plan/<name>/findings.md` given → read it (its `research/` counts as step 3's: reuse, don't redo).
2. `same-page` on the request, bugs too. Agreed, and it's something broken to track down (bug, error, failing test, incident, alert) → read [investigate.md](investigate.md); come back only to plan its fix. Several features that each ship alone → propose an epic in that round.
3. Research quietly per [research.md](research.md), one report per thing the spec needs (how it works here, patterns to follow, versions in use, other repos touched, specs in `docs/specs/` it touches), saved as `research/<topic>.md`.
4. Invoke the `voice` skill (once per session); write `spec.md` per [spec-file.md](spec-file.md). Each `docs/specs/` spec this change makes untrue → edit it to match, replacing each Decision it overturns with the new one and why it changed; git keeps the old wording. Then check it: `Agent` with `subagent_type: wbc:spec-checker` (never a fork or another type), given only paths: `spec.md`, `${CLAUDE_SKILL_DIR}/spec-file.md`, the repo root, `docs/specs/`. Fix each finding you agree with and rerun it (≤2 reruns); the rest → Questions as `Open:`, raised in the walk.
5. Walk it: path, then its decisions and open questions in ≤8 lines; ask to approve or change. Changes → `same-page` on them, edit, walk again; open questions → settle before approval. Explicit approval only → something to build: move the spec to `docs/specs/<name>.md` (epic feature: `docs/specs/<epic>/<feature>.md`, no `NN-`); `status.md` `spec: approved <date> <spec path>`, then each edited spec's path.
6. Upgrades: read [upgrades-file.md](upgrades-file.md).
7. Tasks: read [tasks.md](tasks.md).
8. Reply: folder and spec paths; approved upgrades; MRs in order with repo, branch, task count; next step: `build`. Nothing to build → say `build` closes it.

Tickets: file or link only when asked (`ticket` skill); record in `status.md`, never the spec.

## status.md

```
ticket: <key | URL | none>
spec: <draft | approved YYYY-MM-DD <spec path>[, <edited spec path>…]>
upgrades: <none | draft | approved YYYY-MM-DD>

## MRs
- NN-<mr>: <todo | building | committed | open <url> | merged>
```

Epic: `## Features` instead, `- NN-<feature>: <todo | building | done>`.
