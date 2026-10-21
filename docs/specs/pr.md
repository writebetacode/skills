# PR

`pr` opens, updates, drafts, readies and merges the current branch's pull request, or GitLab merge request, so you never hand-write its title or description. It handles one PR per branch and never comments on its size, since deciding how to split work is planning.

## Why

Writing a title in the repo's style and filling its description template by hand is busywork. After a squash merge, git won't delete the local branch with a plain `git branch -d`, so cleaning up means checking each branch yourself.

## What

It works on GitHub and GitLab, saying "pull request" or "merge request" to match. It matches the repo's title style, fills the repo's template, and squashes on merge unless asked for a merge commit. For stacked PRs, its caller gives the base and the order they merge in. `build` cleans up merged branches the same way when it closes a plan.

## Behaviour

- Asked to open one, it opens one PR for the branch, however many files or concerns it spans, and says nothing about its size or splitting it.
- On the default branch, it won't open one, and says the work needs its own branch.
- It won't merge while checks fail or the branch has commits you haven't pushed.
- After a merge in the main checkout, if nothing's uncommitted and the default branch isn't checked out anywhere else, it switches to the default branch and pulls. Otherwise, as in a linked worktree, it only fetches and stays on its branch.
- It then deletes the local branch once it's fully merged and not checked out anywhere, squash merges included.
- When it keeps a branch, it names it and says why, like a failed fetch or git older than 2.38.

## Decisions

- **Size**: `pr` never sizes a PR. Why: a size warning pushes you to split, which is `plan`'s call, and `pr` can't act on it.
- **Cleanup**: `pr` and `build` clean up the same way, counting a branch as merged when merging it into origin's default branch would change nothing. Why: that catches squash merges, which a plain `git branch -d` refuses. Not two ways that can drift apart.

## Out of scope

- Splitting a branch into several PRs: that's `plan`.
