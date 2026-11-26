#!/bin/sh
# Rebases the current branch onto origin/<base>, fetched, only when it needs it, and prints what it did:
# - it holds commits whose changes origin/<base> already has (a merged MR it was stacked on, squashed or not): it drops
#   the newest such commit and everything older, with --onto;
# - else it conflicts with origin/<base>: a plain rebase;
# - else nothing.
# Exit 1: the rebase stopped on a conflict (still in progress). Exit 2: anything else failed.
# Usage: rebase-if-needed.sh <base>
[ $# -eq 1 ] || { echo "usage: rebase-if-needed.sh <base>" >&2; exit 2; }
base=origin/$1
git fetch --quiet origin "$1" || { echo "couldn't fetch $1 from origin" >&2; exit 2; }
tree=$(git rev-parse --verify --quiet "$base^{tree}") || { echo "no $base" >&2; exit 2; }

rebase() {
  out=$(git rebase "$@" 2>&1) && return 0
  printf '%s\n' "$out" >&2
  if [ -d "$(git rev-parse --git-path rebase-merge)" ] || [ -d "$(git rev-parse --git-path rebase-apply)" ]; then
    echo "stopped on a conflict rebasing onto $base: resolve it, then git rebase --continue; or git rebase --abort" >&2
    exit 1
  fi
  exit 2
}

# Newest first. A commit whose changes the base already has merges into it without changing its tree.
for c in $(git rev-list "$base..HEAD"); do
  if [ "$(git merge-tree --write-tree "$base" "$c" 2>/dev/null | head -n 1)" = "$tree" ]; then
    rebase --onto "$base" "$c"
    echo "rebased onto $base, dropping $(git rev-parse --short "$c") and older: $1 already has their changes"
    exit 0
  fi
done

git merge-tree --write-tree "$base" HEAD > /dev/null 2>&1
case $? in
  0) echo "no rebase needed: no merged work, and it merges cleanly into $base" ;;
  1) rebase "$base"
     echo "rebased onto $base: it conflicted with $1" ;;
  *) echo "git merge-tree failed: needs git 2.38 or later" >&2; exit 2 ;;
esac
