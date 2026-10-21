#!/bin/sh
# Prints the folders a repo keeps its specs in, relative to its root, one per line, most specs first (new specs go in the
# first): each outermost folder named specs that holds tracked Markdown files, wherever it sits (docs/specs,
# docs/superpowers/specs, openspec/specs, .kiro/specs). None: docs/specs. Exits 1 outside a repo.
# Usage: specs-dir.sh [path]
root=$(git -C "${1:-.}" rev-parse --show-toplevel 2>/dev/null) || { echo "not in a git repo: ${1:-.}" >&2; exit 1; }
dirs=$(git -C "$root" ls-files -z -- '*.md' | tr '\0' '\n' | awk -F/ '
  { for (i = 1; i < NF; i++) if ($i == "specs") { p = $1; for (j = 2; j <= i; j++) p = p "/" $j; n[p]++; break } }
  END { for (p in n) printf "%d\t%s\n", n[p], p }' | sort -k1,1nr -k2,2 | cut -f2)
printf '%s\n' "${dirs:-docs/specs}"
