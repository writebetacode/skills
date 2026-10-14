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
| Upgrade path in `plan` | Planned | `plan` proposes the dependency upgrades a feature needs, and you withdraw the ones you don't want. Replaces a separate dependency-upgrade skill. |
| `wbc:spec-checker` agent | Planned | Checks a draft spec against the spec rules, the repo's rules and earlier specs before `plan` walks you through it. |
| Deploy and watch releases | Rejected | Watching the deploy after a release, checking health and offering a rollback. The maintainer doesn't want it. |
| Check changes in the running app | Skipped for now | `build` running the app with Claude Code's `run` skill to prove user-facing criteria, not just tests. |
| Release backports and hotfixes | Proposed | Letting `release` cut versions from maintenance branches, not only the default branch. |
| Catch stale docs in `build` | Proposed | Flagging READMEs and docs a change makes untrue, the way `plan` already does for specs. |
| Multi-day recaps | Proposed | A summary of a week or a sprint for standups and status updates. |
