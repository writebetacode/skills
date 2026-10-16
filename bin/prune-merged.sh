#!/bin/sh
# Cleans up after a merge, in the current checkout. In a linked worktree, or when it can't switch (uncommitted changes,
# the default branch checked out elsewhere), only fetches with pruning and stays put; else switches to origin's default
# branch and pulls with pruning. Then deletes each named local branch that's checked out in no worktree and fully merged
# into origin's default branch: merging it would change nothing, so squash merges count. Prints each branch it deletes
# or keeps, with why; a step that fails keeps the branch.
# Usage: prune-merged.sh <branch>...
[ $# -gt 0 ] || { echo "usage: prune-merged.sh <branch>..." >&2; exit 1; }
d=$("$(dirname "$0")/default-branch.sh") || exit 1
if [ "$(git rev-parse --path-format=absolute --git-dir)" != "$(git rev-parse --path-format=absolute --git-common-dir)" ] ||
  [ -n "$(git status --porcelain --untracked-files=no)" ] || ! git switch -q "$d" 2>/dev/null; then
  synced=$(git fetch -q --prune origin 2>&1) || { for b; do echo "kept $b: fetch failed: $synced"; done; exit 1; }
else
  synced=$(git pull -q --prune 2>&1) || { for b; do echo "kept $b: pull failed: $synced"; done; exit 1; }
fi
tree=$(git rev-parse "origin/$d^{tree}") || exit 1
for b; do
  if ! git show-ref --verify -q "refs/heads/$b"; then echo "$b: no local branch"
  elif git worktree list --porcelain | grep -qx "branch refs/heads/$b"; then echo "kept $b: checked out in a worktree"
  elif [ "$(git merge-tree --write-tree "origin/$d" "$b" 2>/dev/null)" != "$tree" ]; then echo "kept $b: not fully merged into origin/$d"
  elif git branch -q -D "$b"; then echo "deleted $b"
  else echo "kept $b: git branch -D failed"
  fi
done
