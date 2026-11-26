Land: make each open PR/MR mergeable; never merge. Plan → its `open` MRs in NN order; else the one given. Each in its repo: step 1, then on its branch, fetched. Remote commands only from [../pr/github.md](../pr/github.md) or [../pr/gitlab.md](../pr/gitlab.md); `threads`, `comments`, `reply` from [../review/github.md](../review/github.md) or [../review/gitlab.md](../review/gitlab.md).

1. `view`. Merged → `status.md` `merged`; next. Its author isn't you (`user`) → `review` skill on it; stop.
2. `origin/<branch>` has commits HEAD lacks → `git rebase origin/<branch>`. Base: plan → as in Task step 1; else the PR's base. Host's base differs → `edit-base`. Then `<this skill's base directory>/rebase-if-needed.sh <base>`: it rebases only when the branch holds a merged MR's work or conflicts with the base, and says what it did. Exit 1 (a conflict): resolve it only where both sides' intent is clear, then `git rebase --continue`; else `git rebase --abort`, report; stop.
3. CI: [ci.md](ci.md).
4. Threads: unresolved `threads` and `comments` whose last comment isn't the user's (`user`). Each: a change that's right and in scope → make it per Task step 2; else draft a reply: the answer, or why not. One changing a spec, or its ticket's what, why or ACs → stop; `plan` (revise).
5. Anything changed → Task step 3.
6. Stop; nothing to do → say it's ready to merge. Else reply per PR: rebased onto; CI fixes; thread fixes; reply drafts verbatim; what's left. End: "Look it over; say go to commit, push and post."

Go: changes → `commit` skill, staging by path; `git push`, plus `--force-with-lease` if rebased; `reply` each draft; never resolve a thread, a bot's included: its opener, else the user, decides when it's settled, and a resolved one collapses before they check the fix. Then `checks`; failed → steps 3–6 again; 3 rounds → stop with what's left.
