# Proposed improvements

Ideas for new skills, agents and features in this plugin, and what we decided about each. Check here before proposing something: a rejected idea stays rejected, so it shouldn't come back.

Each idea has one status:

- **Proposed**: suggested, not decided yet.
- **Planned**: agreed and on the way.
- **Done**: shipped.
- **Skipped for now**: not now, maybe later.
- **Rejected**: never.

| Idea | Status | Notes |
| --- | --- | --- |
| `wbc:setup` skill | Done | Checks your CLIs, links related repos and lists debug tools in each repo's `CLAUDE.local.md`. |
| `wbc:daily` skill | Done | Replaces `recap`: plans your morning from what's waiting on you, then recaps what you did. |
| Ticket triage | Done | Becomes part of `daily`'s morning instead of a skill of its own. |
| Upgrade path in `plan` | Done | `plan` proposes the dependency upgrades a feature needs, and you withdraw the ones you don't want. Replaces a separate dependency-upgrade skill. |
| `wbc:spec-checker` agent | Done | Checks a draft spec against the spec rules, the repo's rules and earlier specs before `plan` walks you through it. |
| Deploy and watch releases | Rejected | Watching the deploy after a release, checking health and offering a rollback. The maintainer doesn't want it. |
| Check changes in the running app | Skipped for now | `build` running the app with Claude Code's `run` skill to prove user-facing criteria, not just tests. |
| Release backports and hotfixes | Proposed | Letting `release` cut versions from maintenance branches, not only the default branch. |
| Catch stale docs in `build` | Proposed | Flagging READMEs and docs a change makes untrue, the way `plan` already does for specs. |
| Multi-day recaps | Proposed | A summary of a week or a sprint for standups and status updates. |
| Spec clashes in `review` | Planned | `review` reads the specs covering what a PR touches and blocks wherever the code no longer matches one, asking whether the code or the spec should change. |
| Learn from your sessions in `setup` | Planned | Re-running `setup` combs recent sessions for corrections you keep making and proposes lines for each repo's `CLAUDE.local.md`. Where a wbc skill went wrong, it drafts an issue here from a made-up scenario, with nothing that identifies you. |
| Split a branch in `plan` | Planned | `plan` turns a branch that grew too big into tasks that reuse its code and tests. `pr` never splits: it handles one PR on one branch. |
| Living specs in `plan` | Planned | One spec per domain area in a flat `docs/specs/`, named for the area and updated with every change to it. |
| `build` hands doubt to `plan` | Planned | `build` stops running `same-page` on requests. It builds what's already decided, and anything it isn't sure about goes to `plan`. |
| Find related tickets before filing | Planned | `ticket` searches open and closed tickets first. A closed match is linked as related, one in progress (on GitHub, one with an open PR) gets a follow-up ticket, and one not started gets updated instead. |
| Catch up on PR activity in `daily` | Planned | `daily` re-reviews PRs you reviewed that have new pushes or replies, in your local review files only, and lists new comments on your own PRs. Asking to address a PR's comments goes to `build` for yours and `review` for ones you reviewed. |
| Watch your PRs on a loop | Rejected | Fixing CI and drafting replies in a long-running loop. The maintainer wants to ask when they're ready instead. |
| Share `.ai/` across worktrees | Done | Skills keep `.ai/` in the repo's main checkout, never in a worktree Claude spun up, so every plan and review is in one place. |
| Security alerts in `daily` | Planned | `daily` lists security alerts and dependency-update PRs at any severity in every active repo (related repos, plus any with a session this past week), and checks the others for the same issue so `plan` can fix them together. |
| Track down flaky tests | Planned | When CI fails on a test that passes locally, `build` hands it to `plan`'s investigation to find what makes it fail only sometimes. |
| CI for this repo | Skipped for now | Running `check.py` and markdownlint on PRs. Not needed while one person maintains it. |
| README section check | Skipped for now | `check.py` checking that each skill has its README section. Not needed while one person maintains it. |
