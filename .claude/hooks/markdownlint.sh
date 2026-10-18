#!/usr/bin/env bash
# PostToolUse hook: fix Markdown Claude just changed in this repo with bin/lint-md.sh (AGENTS.md rule).
# Edit/Write: the edited file. Bash: changed or new .md files (e.g. a CHANGELOG.md written by a shell
# command) touched since this hook last ran. Errors it can't fix go back to Claude (exit 2).
set -uo pipefail

input=$(cat)
root=${CLAUDE_PROJECT_DIR:-$(pwd)}
cd "$root" || exit 0

if [ "$(jq -r '.tool_name // empty' <<<"$input")" = Bash ]; then
  stamp="${TMPDIR:-/tmp}/markdownlint-$(printf %s "$root" | cksum | cut -d' ' -f1).stamp"
  files=()
  while IFS= read -r f; do
    [ -f "$f" ] && { [ ! -e "$stamp" ] || [ "$f" -nt "$stamp" ]; } && files+=("$f")
  done < <(git ls-files -m -o --exclude-standard -- '*.md' 2>/dev/null)
  touch "$stamp"
  [ ${#files[@]} -eq 0 ] && exit 0
else
  f=$(jq -r '.tool_input.file_path // empty' <<<"$input")
  case "$f" in
    "$root"/*.md) [ -f "$f" ] || exit 0 ;;
    *) exit 0 ;;
  esac
  files=("$f")
fi

out=$(bin/lint-md.sh "${files[@]}" 2>&1) && exit 0
printf '%s\n' "$out" >&2
exit 2
