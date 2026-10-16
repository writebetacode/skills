---
name: build
description: Build a plan, findings or small change test-first into reviewed PRs, then land them: rebase, fix CI, answer threads. Use when asked to build or implement something, continue or close out a plan, or get a PR green or through review.
---

Input, first match:

- PR/MR number or URL, or the current branch's when asked to get it green or through review → read [land.md](land.md).
- A plan: `<${CLAUDE_SKILL_DIR}/../plan/ai-dir.sh plan>/<name>/` as named; nothing given → the only one outside `completed/` with a `status.md` or `findings.md`; several → ask. No approved spec but a `findings.md` → as findings, below. Epic → its first `NN-<feature>/` not `done` in the epic's `status.md`; set it `building`. `spec:` neither `approved` nor `none` (only upgrades), or `upgrades: draft` → `plan`; stop.
- A request, or findings (`.ai/plan/<name>/findings.md`: its recommended fix): fits one PR and nothing about it is in doubt (what changes, where, what done looks like) → one task, no folder; else (splitting a branch included) → `plan` skill; stop. Never `same-page` a request: write its ACs from it as asked. Findings → its repro is the first AC.

Plan: the specs on `status.md`'s `spec:` line, read from the plan's `specs/`, are the source of truth: read each whole; never `research/`, `findings.md` or tickets. Next task: the first `tasks/NN-*.md` with an unticked AC, its first task with one. None left, or no `tasks/` → read [finish.md](finish.md).

Work in the MR's `repo:` path (a main checkout), or in the current checkout when `${CLAUDE_SKILL_DIR}/../plan/main-checkout.sh` prints that path: `cd` there before tests, `branch`, `commit`, `pr`. Host, per repo: `${CLAUDE_SKILL_DIR}/../pr/host.sh` there (fails → ask). MR state: `view` in [../pr/github.md](../pr/github.md) or [../pr/gitlab.md](../pr/gitlab.md); seen merged → `status.md` `merged`.

Edit/Write refused on a main-checkout `.ai/` file (worktree session) → Bash, plain separate commands (a compound one is refused): `mkdir -p <folder>`, then the whole file via `cat > <file> <<'<TAG>'`, `<TAG>` matching no line of it. `ai-dir.sh --write` exits 1 → write that `.ai/.gitignore` holding `*` either way; run it again. A shell write or that rerun failing → say you can't reach the main checkout; stop. Never the worktree's copy.

## Task

1. Branch: plan → the MR's `branch:` exists → switch to it. Else base = its `base:`; while that base is an MR branch whose MR has merged → that MR's `base:`. `branch` skill with both. `status.md` MR → `building`. Request or findings → `branch` skill, named from it.
   Then plan specs: each on the `spec:` line for this repo whose `specs/` copy differs from the checkout's `docs/specs/` one: fetch; its `origin/<default>` version (`${CLAUDE_SKILL_DIR}/../branch/default-branch.sh`; or absence) matches, by blob id (`git rev-parse <commit>:<path>`; the copy: `git hash-object`), neither its entry commit's, the copy's, nor any commit's in `git log --format=%H origin/<default>..<branch> -- <path>` for this plan's MR branches, local or `origin/` → someone else changed it: hand the plan back to `plan` (revise); build nothing. Else write the copy into `docs/specs/`.
2. A `from:` task → [carry.md](carry.md) too. Each AC: a test, written the repo's way, that fails for the reason the AC names; run it; see it fail. Then the least code that passes. Docs, write-ups, config → no test. Then the full suite and the repo's linter. Never weaken a test.
3. Review: one fresh `Agent`, briefed: `Follow ${CLAUDE_SKILL_DIR}/../review/SKILL.md for a local review of the uncommitted changes in <repo path>, against <this repo's docs/specs paths on the spec line, else the task file | findings path | the request, verbatim>; ACs: <names>; later work, not yet built: <the plan's later tasks and MRs, by title | none>.` Its findings and `git diff HEAD` plus untracked files (temp files), the spec, task or findings path (a request: temp file) and the repo path → `Agent` with `subagent_type: wbc:review-checker`. Fix each survivor, re-run tests, review again with new agents until none survive. A finding you think wrong → leave it for the user. 3 rounds → stop with what's left.
4. Stop. Reply: the task; each AC with its test `path:line`; files changed; review: found → fixed per round; disputed findings. End: "Look it over; say go to commit."

The user asks for changes: code only → make them, steps 2–4 again. Changes what the spec says or means, or outgrows one PR → stop; `plan` (revise, or new for a request); resume from its tasks once approved.

Go:

1. Stage the task's files by path, never `-A` or `.`, plus each spec on `status.md`'s `spec:` line that's untracked or changed in this repo; `commit` skill.
2. Plan: tick the task's ACs. MR's last task → `status.md` `committed`. Start the next task unasked. The feature's last commit → [finish.md](finish.md).
3. Request or findings: ask to open the PR. Yes → `pr` skill: open; then land.md.
