Local review of uncommitted changes: no PR, host commands, worktree, file, threads or posting.

- Diff: `git diff HEAD` plus untracked files; read code in the current checkout.
- Review steps 1–4, the spec and the caller's ACs (else the request) standing in for ticket and description. With a spec, also: each AC has a test that would fail without the change; the code follows the spec's Design and Decisions.
- Step 6 as written; running as a subagent (no `Agent`) → apply the checker's bar to each finding yourself.
- Reply with only the survivors as File findings (heading, The ask, summary, Example), numbered blocking first, or `No findings.`
