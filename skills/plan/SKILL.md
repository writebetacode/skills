---
name: plan
description: Plan work into specs and tasks you approve. Use when asked to plan, spec or scope work, plan a fix from findings, or split a branch.
---

Before any text for a person (replies, questions, files, posts): invoke the `voice` skill, once per session. Never for text only an agent reads.

A change to an existing plan, asked or handed back by `build` → read [revise.md](revise.md). Splitting a branch → plan it as below, with [split.md](split.md).

Folder: `<${CLAUDE_PLUGIN_ROOT}/bin/ai-dir.sh --write plan>/<name>/` (exits 2 → stop), `<name>` 2–4 kebab-case words, not already there.

Edit/Write refused on a main-checkout `.ai/` file (worktree session) → Bash, each a plain command: `mkdir -p <folder>`, then the whole file via `cat > <file> <<'<TAG>'`, `<TAG>` in no line of it. Refused too, or `ai-dir.sh` fails again → say you can't reach the main checkout; stop. Never the worktree's copy.

After writing or editing a `.md` file: `${CLAUDE_PLUGIN_ROOT}/bin/lint-md.sh <file>…`; fix what it prints, rerun until clean.

```
specs/<area>.md      one per domain area the change touches (step 4); build commits them
status.md            ticket, spec, progress
research/<topic>.md  one report each
tasks/NN-<mr>.md     one per MR; NN = merge order
```

Related repos: `${CLAUDE_PLUGIN_ROOT}/bin/related-repos.sh` (name, path, how).

Talk to the user only in `same-page` rounds (the request, then each open choice the specs or tasks need), the spec walk, and the final reply. Never ask them to approve research. Write only this folder; run no experiments yourself.

## Plan

1. Inputs only, nothing else before `same-page`: ticket key or URL → `ticket` skill: view; `.ai/research/<name>/findings.md` given → read it (its `research/` counts as step 3's: reuse, don't redo).
2. `same-page` on the request, bugs too. Agreed, and it's something broken to track down (bug, error, failing test, incident, alert) → `research` skill on it; then plan its recommended fix. Only a dependency upgrade (from `build`, outgrowing one PR) → no spec (`spec: none`): steps 3, 6 and 7. Speccing an area as it is today, changing nothing → each spec says what the code does now (why: from its history, else `Open:`); no AC from any (step 6).
3. Research: `research` skill once per thing the specs or tasks need (how it works here, patterns to follow, versions in use and which dependencies it needs newer (to what version, each breaking change with where), other repos touched, the domain areas it touches and their `docs/specs/` specs, a choice only trying settles), saved as `research/<topic>.md`.
4. Write `specs/<area>.md` for each area the request touches and each other area's spec it makes untrue: start each per [copy.md](copy.md), then write it per [spec-file.md](spec-file.md). Then check each: `Agent` with `subagent_type: wbc:spec-checker` (never a fork or another type), once per spec, given only paths: that spec, `${CLAUDE_SKILL_DIR}/spec-file.md`, the root and `docs/specs/` of the repo it ships in, and this plan's other `specs/*.md`. Fix each finding you agree with and rerun it (≤2 reruns); the rest → that spec's Questions as `Open:`, raised in the walk.
5. Walk them: each path, then its decisions and open questions in ≤8 lines; ask to approve or change. Changes → `same-page` on them, edit, check, walk again; open questions → settle before approval. Explicit approval only → `status.md`'s `spec: draft` → `spec: approved <date>`, keeping its entries.
6. Tasks: read [tasks.md](tasks.md), and [split.md](split.md) when `status.md` has a `from:` branch. A repo whose specs change but that gets no task → one MR there, one task: `- [ ] specs ship (docs only: no new test)`.
7. Reply: folder and spec paths; MRs in order with repo, branch, task count; next step: `build`. Nothing to build → say `build` closes it.

Tickets: file or link only when asked (`ticket` skill); record in `status.md`.

## status.md

```
ticket: <key | URL | none>
spec: <none | draft | approved YYYY-MM-DD>[: <repo>@<commit> <docs/specs path>, …]
from: <split branch | none>

## MRs

- NN-<mr>: <todo | building | committed | open <url> | merged>
```
