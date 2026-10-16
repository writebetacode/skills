Remote commands only from this table, plus `view`, `threads` and `comments` in [../review/github.md](../review/github.md) or [../review/gitlab.md](../review/gitlab.md), each naming its PR's repo: `{owner}`/`{repo}` filled in, and `--repo` on `gh pr` and `glab mr` commands (GitHub: `<owner/name>`; GitLab: its `https://<host>/<path>` URL).

| Need | Command |
| --- | --- |
| GitHub: reviewed | `gh search prs --reviewed-by=@me --state=open --sort updated --json number,title,repository,url,author`, skipping your own |
| GitHub: head, reviews | `gh pr view <n> --repo <owner/name> --json headRefOid,reviews`; your latest review's `commit.oid` |
| GitLab: reviewed | `glab api --hostname <host> "merge_requests?scope=all&reviewer_username=<login>&state=opened&per_page=100"` (`sha`: head) |
| GitLab: your last word | `glab api --hostname <host> "projects/<url-encoded path>/merge_requests/<iid>/notes?sort=desc"`: your latest note, approvals included |

Each reviewed PR's repo: the active repo whose `origin` is the PR's repo. Its review file: `<this skill's base directory>/../../bin/ai-dir.sh reviews <repo>`/`<number>.md`.

- It exists, and its `reviewed at` isn't the head, or a thread holding one of its `posted:` findings has someone else's reply (`createdAt`; GitLab `created_at`) newer than the file → re-review it now, one PR at a time: the `review` skill on it, that checkout as the repo, each command one call starting `cd <checkout> &&` (the shell's folder resets; a worktree session's own repo: the worktree, no `cd`). List it under Reviews: what changed in its file, and `/wbc:review <number>` to look it over and post.
- No file, or no active repo, and new pushes since your latest review (GitHub: that review's commit isn't the head; GitLab: commits newer than your last word) → list it under Reviews with `/wbc:review <url>`; run nothing.

Each other `<number>.md` in an active repo's review folder: `view` its PR (per its checkout's `origin`). Merged or closed → unasked, `mkdir -p <folder>/completed`, then `mv -n` it there; reply `Archived: <repo> #<number>`. Still there → say why.
