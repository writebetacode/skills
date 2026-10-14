---
name: build
description: Build a plan, findings or small change test-first into reviewed PRs, then land them: rebase, fix CI, answer threads. Use when asked to build or implement something, continue or close out a plan, or get a PR green or through review.
---

Input, first match:

- PR/MR number or URL → read [land.md](land.md).
- A plan: `<repo root>/.ai/plan/<name>/` as named, else the only one outside `completed/` with a `status.md`; several → ask. No approved spec but a `findings.md` → as findings, below. Epic → its first `NN-<feature>/` not `done` in the epic's `status.md`; set it `building`. `spec: approved` missing, or `upgrades: draft` → `plan`; stop.
- A request, or findings (`.ai/plan/<name>/findings.md`: its recommended fix): fits one PR with no open design choices → one task, no folder; else → `plan` skill; stop. Request → `same-page` on it first; its examples are the ACs. Findings → its repro is the first AC.

Plan: the spec at the first path on `status.md`'s `spec:` line is the source of truth: read it whole; never `research/`, `findings.md` or tickets. Next task: the first `tasks/NN-*.md` with an unticked AC, its first task with one. None left, or no `tasks/` → read [finish.md](finish.md).

Work in the MR's `repo:` path: `cd` there before tests, `branch`, `commit`, `pr`. Host, per repo: `${CLAUDE_SKILL_DIR}/../pr/host.sh` there (fails → ask). MR state: `view` in [../pr/github.md](../pr/github.md) or [../pr/gitlab.md](../pr/gitlab.md); seen merged → `status.md` `merged`.

## Task

1. Branch: plan → the MR's `branch:` exists → switch to it. Else base = its `base:`; while that base is an MR branch whose MR has merged → that MR's `base:`. `branch` skill with both. `status.md` MR → `building`. Request or findings → `branch` skill, named from it.
2. Each AC: a test, written the repo's way, that fails for the reason the AC names; run it; see it fail. Then the least code that passes. Docs, write-ups, config → no test. Then the full suite and the repo's linter. Never weaken a test.
3. Review: one fresh `Agent`, briefed: `Follow ${CLAUDE_SKILL_DIR}/../review/SKILL.md for a local review of the uncommitted changes in <repo path>, against <spec path | findings path | the agreed request, verbatim>; ACs: <names>.` Its findings and `git diff HEAD` plus untracked files (temp files), the spec or findings path (a request: temp file) and the repo path → `Agent` with `subagent_type: wbc:review-checker`. Fix each survivor, re-run tests, review again with new agents until none survive. A finding you think wrong → leave it for the user. 3 rounds → stop with what's left.
4. Stop. Reply: the task; each AC with its test `path:line`; files changed; review: found → fixed per round; disputed findings. End: "Look it over; say go to commit."

The user asks for changes: code only → make them, steps 2–4 again. Changes what the spec says or means, or outgrows one PR → stop; `plan` (revise, or new for a request); resume from its tasks once approved.

Go:

1. Stage the task's files by path, never `-A` or `.`, plus each spec on `status.md`'s `spec:` line that's untracked or changed in this repo; `commit` skill.
2. Plan: tick the task's ACs. MR's last task → `status.md` `committed`. Start the next task unasked. The feature's last commit → [finish.md](finish.md).
3. Request or findings: ask to open the PR. Yes → `pr` skill: open; then land.md.
