daily's own remote commands only from this table (`review` runs its own), plus `threads` and `comments` in [../review/github.md](../review/github.md) or [../review/gitlab.md](../review/gitlab.md) for your own PRs, each naming its PR's repo: `{owner}`/`{repo}` filled in, and `--repo` on `gh pr` and `glab mr` commands (GitHub: `<owner/name>`; GitLab: its `https://<host>/<path>` URL).

| Need | Command |
| --- | --- |
| GitHub: reviewed | `gh search prs --reviewed-by=@me --state=open --sort updated --json number,title,repository,url,author`, skipping your own |
| GitHub: head, reviews | `gh pr view <n> --repo <owner/name> --json headRefOid,reviews`; your latest review's `commit.oid` |
| GitLab: reviewed | `glab api --hostname <host> "merge_requests?scope=all&reviewer_username=<login>&state=opened&per_page=100"` (`sha`: head) |
| GitLab: your last word | `glab api --hostname <host> "projects/<url-encoded path>/merge_requests/<iid>/notes?sort=desc"`: your latest note, approvals included |

Each PR you reviewed: its repo is the active repo whose `origin` is the PR's repo; its review file `<this skill's base directory>/../../bin/ai-dir.sh reviews <repo>`/`<number>.md`.

- It exists → the `review` skill on it now, in this session, one PR at a time, that checkout as the repo, each command one call starting `cd <checkout> &&` (the shell's folder resets; a worktree session's own repo: the worktree, no `cd`); it re-reviews or says it's current. One that stops → say why; next. Re-reviewed → list it under Reviews: what changed in its file, and `/wbc:review <number>` to look it over and post.
- Else, new pushes since your latest review (GitHub: that review's commit isn't the head; GitLab: commits newer than your last word) → list it under Reviews with `/wbc:review <url>`; run nothing.
