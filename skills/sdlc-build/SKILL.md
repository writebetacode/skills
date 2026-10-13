---
name: sdlc-build
description: Build a planned `.ai/sdlc/<name>/` folder (from sdlc-plan) task by task through to merge requests. Use when asked to build, implement, continue or finish a planned feature, epic or task, or to close out a plan.
---

Folder: `<repo root>/.ai/sdlc/<name>/` as named, else the only one outside `completed/`; several → ask. Epic → its first `NN-<feature>/` not `done` in the epic's `status.md`; set it `building`. `spec: approved` missing → `sdlc-plan`; stop.

`spec.md` is the source of truth: read it whole; never research or tickets.

Next task: the first `tasks/NN-*.md` with an unticked AC, its first task with one. None left, or no `tasks/` → read [finish.md](finish.md).

Work in the MR's `repo:` path: `cd` there before tests, `branch`, `commit`, `pr`. MR state: `view` in [../pr/github.md](../pr/github.md) or [../pr/gitlab.md](../pr/gitlab.md) by `origin`'s host; seen merged → `status.md` `merged`.

## Task

1. Branch: the MR's `branch:` exists → switch to it. Else base = its `base:`; while that base is an MR branch whose MR has merged → that MR's `base:`. `branch` skill with both. `status.md` MR → `building`.
2. Each AC: a test, written the repo's way, that fails for the reason the AC names; run it; see it fail. Then the least code that passes. Docs, write-ups, config → no test. Then the full suite and the repo's linter. Never weaken a test.
3. Review: one fresh `Agent`, briefed: `Follow ${CLAUDE_SKILL_DIR}/../review/SKILL.md for a local review of the uncommitted changes in <repo path>, against <spec path>; ACs: <names>.` Its findings (temp file), `git diff HEAD` (temp file), the spec path and the repo path → `Agent` with `subagent_type: wbc:review-checker`. Fix each survivor, re-run tests, review again with new agents until none survive. A finding you think wrong → leave it for the user. 3 rounds → stop with what's left.
4. Stop. Reply: the task; each AC with its test `path:line`; files changed; review: found → fixed per round; disputed findings. End: "Look it over; say go to commit."

The user asks for changes: code only → make them, steps 2–4 again. Changes what the spec says or means → stop; `sdlc-plan` (revise); resume from its rewritten tasks once approved.

Go:

1. Stage the task's files by path, never `-A` or `.`; `commit` skill.
2. Tick the task's ACs. MR's last task → `status.md` `committed`.
3. Start the next task unasked. The feature's last commit → [finish.md](finish.md).
