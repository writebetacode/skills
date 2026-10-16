#!/bin/sh
# Prints the repos you're active in, one main checkout per line, deduplicated: the main checkouts of the folders your
# Claude Code sessions ran in over the past <days> (default 7; temp folders skipped), plus each path listed under
# "## Related repos" in those checkouts' CLAUDE.md and CLAUDE.local.md, resolved from the checkout.
# Usage: active-repos.sh [days]
days=${1:-7}
dir=${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects
[ -d "$dir" ] || { echo "no sessions folder: $dir" >&2; exit 1; }
main=$(dirname "$0")/../plan/main-checkout.sh
checkouts=$(find "$dir" -name '*.jsonl' -mtime "-$days" -exec grep -ho '"cwd":"[^"]*"' {} + 2>/dev/null | sort -u |
  sed 's/^/{/; s/$/}/' | jq -r '.cwd' 2>/dev/null | grep -Ev '^(/private)?/(tmp|var/folders)/' |
  while IFS= read -r cwd; do "$main" "$cwd" 2>/dev/null; done | sort -u)
{
  printf '%s\n' "$checkouts"
  printf '%s\n' "$checkouts" | while IFS= read -r repo; do
    [ -n "$repo" ] || continue
    for f in "$repo/CLAUDE.md" "$repo/CLAUDE.local.md"; do
      [ -f "$f" ] || continue
      # Each "- name (path): how" line under "## Related repos", up to the next "## " heading.
      awk '/^## /{on = ($0 ~ /^## Related repos[[:space:]]*$/); next} on && /^- / && match($0, /\([^)]+\)/) {
        print substr($0, RSTART + 1, RLENGTH - 2) }' "$f" |
      while IFS= read -r p; do
        case $p in /*) ;; "~"/*) p=$HOME/${p#"~"/} ;; *) p=$repo/$p ;; esac
        "$main" "$p" 2>/dev/null
      done
    done
  done
} | grep -v '^$' | sort -u
