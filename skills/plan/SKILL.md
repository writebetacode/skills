---
name: plan
description: Plan work, answer questions or prove why something's broken. Use when asked to plan, spec or scope work, or split a branch; to look into how something works here, which pattern to follow or versions in use; to debug a bug, error, failing test, incident or alert; or to write up findings or a postmortem.
---

Just a question to answer (how something works here, which pattern to follow, versions in use) → follow only [research.md](research.md). A change to an existing plan, asked or handed back by `build` → read [revise.md](revise.md). Splitting a branch → plan it as below, with [split.md](split.md). A failing CI test handed over by `build` → read [handover.md](handover.md). A plan at `upgrades: draft` → resume step 6's walk; then `tasks/` exists → revise.md's task rewrite, else step 7.

Folder: `<${CLAUDE_PLUGIN_ROOT}/bin/ai-dir.sh --write plan>/<name>/` (exits 2 → stop), `<name>` 2–4 kebab-case words, not already there.

Edit/Write refused on a main-checkout `.ai/` file (worktree session) → Bash, plain separate commands (a compound one is refused): `mkdir -p <folder>`, then the whole file via `cat > <file> <<'<TAG>'`, `<TAG>` matching no line of it. `ai-dir.sh --write` exits 1 → write that `.ai/.gitignore` holding `*` either way; run it again. A shell write or that rerun failing → say you can't reach the main checkout; stop. Never the worktree's copy.

```
specs/<area>.md      one per domain area the change touches (step 4); build commits them
spec.md              defines no area: an epic's features, a research answer; never committed
status.md            ticket, spec, progress
findings.md          a bug's proven cause (investigate.md)
upgrades.md          dependency upgrades the feature needs (step 6)
research/<topic>.md  one report each
tasks/NN-<mr>.md     one per MR; NN = merge order
```

Epic (several features that each ship alone): its own `spec.md` (Design: its features in build order, a line each) and `status.md`, plus `NN-<feature>/` sub-folders in build order, each laid out as above.

Related repos: `${CLAUDE_PLUGIN_ROOT}/bin/related-repos.sh` (name, path, how). Debug tools: that section of the `CLAUDE.md` and `CLAUDE.local.md` in `${CLAUDE_PLUGIN_ROOT}/bin/main-checkout.sh`'s checkout.

Talk to the user only in `same-page` rounds (the request, then each open choice the spec needs), the spec and upgrade walks, and the final reply. Never ask them to approve research. Write only this folder; outside investigate.md, run no experiments.

## Plan

1. Inputs only, nothing else before `same-page`: ticket key or URL → `ticket` skill: view; `.ai/plan/<name>/findings.md` given → read it (its `research/` counts as step 3's: reuse, don't redo).
2. `same-page` on the request, bugs too. Agreed, and it's something broken to track down (bug, error, failing test, incident, alert) → read [investigate.md](investigate.md); come back only to plan its fix. Several features that each ship alone → propose an epic in that round. Only a dependency upgrade (a security fix `daily` found, say) → steps 3 and 6–8 only, invoking `voice` before the walk.
3. Research quietly per [research.md](research.md), one report per thing the spec needs (how it works here, patterns to follow, versions in use, other repos touched, the domain areas it touches and their `docs/specs/` specs), saved as `research/<topic>.md`.
4. Invoke the `voice` skill (once per session); write `specs/<area>.md` for each area the request touches and each other area's spec it makes untrue: start each per [copy.md](copy.md), then write it per [spec-file.md](spec-file.md). Then check each: `Agent` with `subagent_type: wbc:spec-checker` (never a fork or another type), once per spec, given only paths: that spec, `${CLAUDE_SKILL_DIR}/spec-file.md`, the root and `docs/specs/` of the repo it ships in, and this plan's other `specs/*.md` (epic: every unbuilt feature's too). Fix each finding you agree with and rerun it (≤2 reruns); the rest → that spec's Questions as `Open:`, raised in the walk.
5. Walk them: each path, then its decisions and open questions in ≤8 lines; ask to approve or change. Changes → `same-page` on them, edit, check, walk again; open questions → settle before approval. Explicit approval only → `status.md`'s `spec: draft` → `spec: approved <date>`, keeping its entries. The specs stay here until `build` commits them.
6. Upgrades: read [upgrades-file.md](upgrades-file.md).
7. Tasks: read [tasks.md](tasks.md), and [split.md](split.md) when `status.md` has a `from:` branch.
8. Reply: folder and spec paths; approved upgrades; MRs in order with repo, branch, task count; next step: `build`. Nothing to build → say `build` closes it.

Tickets: file or link only when asked (`ticket` skill); record in `status.md`, never the spec.

## status.md

```
ticket: <key | URL | none>
spec: <none | draft | approved YYYY-MM-DD>[: <repo>@<commit> <docs/specs path>, …]
upgrades: <none | draft | approved YYYY-MM-DD>
from: <split branch | none>

## MRs
- NN-<mr>: <todo | building | committed | open <url> | merged>
```

Epic: `## Features` instead, `- NN-<feature>: <todo | building | done>`.
