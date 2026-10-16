#!/bin/sh
# Prints the repos you're active in, one main checkout per line, deduplicated: the main checkouts of the folders your
# Claude Code sessions ran in over the past <days> (default 7; temp folders skipped), plus each path listed under
# "## Related repos" in those checkouts' CLAUDE.md and CLAUDE.local.md (bin/related-repos.sh).
# Usage: active-repos.sh [days]
days=${1:-7}
dir=${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects
[ -d "$dir" ] || { echo "no sessions folder: $dir" >&2; exit 1; }
checkouts=$(find "$dir" -name '*.jsonl' -mtime "-$days" -exec grep -ho '"cwd":"[^"]*"' {} + 2>/dev/null | sort -u |
  sed 's/^/{/; s/$/}/' | jq -r '.cwd' 2>/dev/null | grep -Ev '^(/private)?/(tmp|var/folders)/' |
  while IFS= read -r cwd; do "$(dirname "$0")/../../bin/main-checkout.sh" "$cwd" 2>/dev/null; done | sort -u)
{
  printf '%s\n' "$checkouts"
  printf '%s\n' "$checkouts" | while IFS= read -r repo; do
    [ -n "$repo" ] || continue
    "$(dirname "$0")/../../bin/related-repos.sh" "$repo" 2>/dev/null | cut -f2 |
      while IFS= read -r p; do "$(dirname "$0")/../../bin/main-checkout.sh" "$p" 2>/dev/null; done
  done
} | grep -v '^$' | sort -u
