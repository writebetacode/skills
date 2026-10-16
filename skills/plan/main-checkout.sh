#!/bin/sh
# Prints the absolute path of the main checkout for a folder (default: the current one), where skills keep .ai/.
# A folder under <checkout>/.claude/worktrees/<name>/ (Claude Code's worktrees), still there or removed, maps as the
# same folder in <checkout> does (so a submodule maps to its own checkout), else as <checkout>. A bare repo has no main
# checkout, so its worktrees map to their own top folder.
# A submodule maps to its own checkout in the superproject's main checkout. Exit 2: a git folder or a bare repo's own
# folder (like the .bare layout's container), never a place to write. Exit 1: not in a repo.
self=$(cd "$(dirname "$0")" && pwd -P)/$(basename "$0")
p=${1:-.}
case $p in /*) ;; *) p=$PWD/$p ;; esac
case $p in
  */.claude/worktrees/*)
    base=${p%%/.claude/worktrees/*}
    sub=${p#"$base"/.claude/worktrees/}
    case $sub in */*) rest=${sub#*/} ;; *) rest= ;; esac
    if [ -n "$rest" ] && [ -d "$base/$rest" ]; then p=$base/$rest; else p=$base; fi ;;
esac
cd "$p" 2>/dev/null || exit 1
for q in --is-inside-git-dir --is-bare-repository; do
  [ "$(git rev-parse "$q" 2>/dev/null)" = true ] && exit 2
done
top=$(git rev-parse --show-toplevel 2>/dev/null) || exit 1
# A submodule checked out in a linked worktree maps as the same submodule in its superproject's main checkout does.
sup=$(git rev-parse --show-superproject-working-tree 2>/dev/null)
if [ -n "$sup" ] && smain=$("$self" "$sup") && [ "$smain" != "$sup" ] && [ -e "$smain/${top#"$sup"/}/.git" ]; then
  exec "$self" "$smain/${top#"$sup"/}"
fi
# The first block of the porcelain list is the main checkout, the bare git folder (marked "bare"), or a git folder: a
# submodule's under the parent's .git/modules/, whose core.worktree names its checkout, or a --separate-git-dir one,
# which names none, so the current checkout's top stands in, as for a bare repo.
main=$(git worktree list --porcelain | awk -v top="$top" '
  NR == 1 { main = substr($0, 10) }
  /^$/ { exit }
  $0 == "bare" { main = top }
  END { print main }')
if [ "$(git -C "$main" rev-parse --is-inside-git-dir 2>/dev/null)" = true ]; then
  main=$(git -C "$main" rev-parse --show-toplevel 2>/dev/null) || main=$top
fi
echo "$main"
