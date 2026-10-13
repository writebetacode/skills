#!/usr/bin/env bash
# PostToolUse hook: fix a Markdown file Claude just edited in this repo with
# markdownlint (AGENTS.md rule). Errors it can't fix go back to Claude (exit 2).
set -uo pipefail

f=$(jq -r '.tool_input.file_path // empty')
root=${CLAUDE_PROJECT_DIR:-$(pwd)}
case "$f" in
  "$root"/*.md) [ -f "$f" ] || exit 0 ;;
  *) exit 0 ;;
esac

cd "$root" || exit 0
# ":" makes markdownlint-cli2 read the path literally, not as a glob.
out=$(npx --yes markdownlint-cli2@0.23.3 --fix ":${f#"$root"/}" 2>&1) && exit 0
printf '%s\n' "$out" >&2
exit 2
