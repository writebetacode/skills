Local review of uncommitted changes: no PR, host commands, worktree, file, threads or posting.

- Diff: `git diff HEAD` plus untracked files; code and specs from the current checkout.
- Review steps 1–4, the spec, task and caller's ACs (else the request) standing in for ticket and description. With a spec or task, also: each AC has a test failing without the change; the code follows the spec's Decisions and the task's how. Step 4's 0s: dropped.
- Step 6, the checkout as worktree; as a subagent (no `Agent`) → skip it: your caller runs the checker.
- Reply with only the survivors (as a subagent: every finding scored 1) in [file.md](file.md)'s form (heading, The ask, summary, Example), numbered blocking first, or `No findings.`; then each related repo's worktree or clone read, one path per line.
