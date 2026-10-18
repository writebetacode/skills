#!/bin/sh
# Fixes Markdown files in place with markdownlint-cli2, then prints what's left to fix by hand (<file>:<line> <rule>) and
# exits 1. A file its repo can commit, in a repo with its own markdownlint setup (a config in the file's folder or one
# above it up to the repo's top, or markdownlint in its package.json), follows that setup, as the repo's linter would.
# Anything else (gitignored, like .ai/ and CLAUDE.local.md; outside a repo; no setup) follows this plugin's
# .markdownlint-cli2.jsonc, read through stdin so no config near the file applies.
# Usage: lint-md.sh <file>...
[ $# -gt 0 ] || { echo "usage: lint-md.sh <file>..." >&2; exit 1; }
plugin=$(cd "$(dirname "$0")/.." && pwd -P)
# --no-globs: a config's globs would lint, and fix, the whole repo.
lint() { npx --yes markdownlint-cli2@0.23.3 --no-globs "$@"; }
# Error lines name the file as markdownlint saw it ($1); print them with its full path ($2) instead.
report() { awk -v from="$1:" -v to="$2:" 'index($0, from) == 1 { $0 = to substr($0, length(from) + 1) } 1' >&2; }
status=0
for f in "$@"; do
  dir=$(cd "$(dirname "$f")" 2>/dev/null && pwd -P) && [ -f "$f" ] || { echo "no such file: $f" >&2; status=1; continue; }
  file=$dir/$(basename "$f")
  own=
  if top=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) && ! git -C "$top" check-ignore -q -- "$file"; then
    d=$dir
    while :; do
      ls -a "$d" | grep -qE '^\.markdownlint(-cli2)?\.(jsonc?|ya?ml|[cm]js)$' && own=1
      [ -n "$own" ] || [ "$d" = "$top" ] || [ "$d" = / ] && break
      d=$(dirname "$d")
    done
    grep -qE '"markdownlint-cli2?"' "$top/package.json" 2>/dev/null && own=1
  fi
  if [ -n "$own" ]; then
    rel=${file#"$top"/}
    # ":" reads the path literally, not as a glob.
    out=$(cd "$top" && lint --fix ":$rel" 2>&1 >/dev/null) || { status=1; printf '%s\n' "$out" | report "$rel" "$file"; }
  else
    tmp=$(mktemp) && (cd "$plugin" && lint --format) < "$file" > "$tmp" && cat "$tmp" > "$file"
    rm -f "$tmp"
    out=$(cd "$plugin" && lint - < "$file" 2>&1 >/dev/null) || { status=1; printf '%s\n' "$out" | report stdin "$file"; }
  fi
done
exit $status
