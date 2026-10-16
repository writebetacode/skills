# Proposed improvements

Ideas for new skills, agents and features in this plugin that haven't shipped, and what we decided about each. Check here before proposing something: a rejected idea stays rejected, so it shouldn't come back. Once an idea ships, its row goes.

Each idea has one status:

- **Proposed**: suggested, not decided yet.
- **Planned**: agreed and on the way.
- **Skipped for now**: not now, maybe later.
- **Rejected**: never.

| Idea | Status | Notes |
| --- | --- | --- |
| Deploy and watch releases | Rejected | Watching the deploy after a release, checking health and offering a rollback. The maintainer doesn't want it. |
| Check changes in the running app | Skipped for now | `build` running the app with Claude Code's `run` skill to prove user-facing criteria, not just tests. |
| Release backports and hotfixes | Skipped for now | Letting `release` cut versions from maintenance branches, not only the default branch. No need for it now. |
| Multi-day recaps | Rejected | A summary of a week or a sprint for standups and status updates. The maintainer will never need it. |
| Watch your PRs on a loop | Rejected | Fixing CI and drafting replies in a long-running loop. The maintainer wants to ask when they're ready instead. |
| CI for this repo | Skipped for now | Running `check.py` and markdownlint on PRs. Not needed while one person maintains it. |
| README section check | Skipped for now | `check.py` checking that each skill has its README section. Not needed while one person maintains it. |
| Test the skill scripts | Rejected | `check.py` running `main-checkout.sh` and `ai-dir.sh` in throwaway repos for the ai-folder spec's cases. The maintainer doesn't want it. |
| One host table per host for pr, review and build | Rejected | Merging the GitHub and GitLab PR commands those three share into one table per host, so build stops reading the other two skills' tables. pr and review would each load commands they never run, just to save build one cross-read. |
