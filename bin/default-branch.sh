#!/bin/sh
# Prints origin's default branch for the repo at $1 (default: the current directory), refreshed from origin: main, not origin/main.
cd "${1:-.}" || exit 1
git remote set-head origin -a > /dev/null 2>&1
ref=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null) || { echo "origin has no default branch" >&2; exit 1; }
echo "${ref#origin/}"
