#!/usr/bin/env bash
# Prints each Claude Code session active on a local day: start time, folder, branch, title, PRs, the user's prompts
# and Claude's last reply that day; then the commits you authored that day in each repo those sessions ran in. Skips
# subagent transcripts and sessions run in temp dirs.
# Usage: sessions.sh [YYYY-MM-DD]   (default: today).
set -euo pipefail
day=${1:-$(date +%F)}
dir=${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects
[ -d "$dir" ] || { echo "no sessions folder: $dir" >&2; exit 1; }

prog='
def local($f): sub("\\.[0-9]+Z$"; "Z") | (try (fromdate | strflocaltime($f)) catch "");
def clip($n): gsub("\\s+"; " ") | if length > $n then .[0:$n] + "…" else . end;
def text: if type == "string" then . else ([.[]? | select(.type? == "text") | .text] | join(" ")) end;
def command: if test("<command-name>") then
    (capture("<command-name>(?<n>[^<]*)</command-name>").n) + " " + ((capture("<command-args>(?<a>[^<]*)</command-args>").a) // "")
  else . end;
[inputs | fromjson? | select(type == "object")] as $all
| ($all | map(select(.isSidechain != true and ((.timestamp // "") | local("%Y-%m-%d")) == $d))) as $today
| ($today | map(select(.type == "user" and .isMeta != true
      and ([.message.content | arrays | .[] | select(.type? == "tool_result")] | length) == 0)
    | .message.content | text
    | select(test("^\\s*<(local-command|system-reminder|task-notification|user-prompt-submit-hook)") | not)
    | command | clip(300) | select(length > 0))) as $prompts
| select($prompts | length > 0)
| ($today | map(select(.cwd)) | last // {}) as $m
| select(($m.cwd // "") | test("^(/private)?/(tmp|var/folders)/") | not)
| ([$all[] | select(.type == "ai-title") | .aiTitle] | last // "") as $title
| ([$today[] | select(.type == "pr-link") | .prUrl] | unique) as $prs
| ([$today[] | select(.type == "assistant") | .message.content | text | select(length > 0)] | last // "" | clip(400)) as $last
| ($today[0].timestamp | local("%H:%M")) as $start
| [ "## \($start) \($m.cwd // "?") (\($m.gitBranch // "no branch"))\(if $title != "" then " · " + $title else "" end)",
    (if ($prs | length) > 0 then "PRs: " + ($prs | join(" ")) else empty end),
    ($prompts[:40][] | "> " + .),
    "Last reply: \($last)",
    "" ]
| "\($start)\t\($m.cwd // "")\t\(join("\u001f"))"
'
# One line per session (start, folder, block with \x1f for its newlines) so sessions sort by start time.
lines=$(find "$dir" -name '*.jsonl' -newermt "$day" -print0 | while IFS= read -r -d '' f; do
  jq -nrR --arg d "$day" "$prog" "$f" || echo "(couldn't read $f)" >&2
done | sort)
[ -n "$lines" ] || { echo "No sessions on $day."; exit 0; }
printf '%s\n' "$lines" | cut -f3- | tr '\037' '\n'

echo "# Commits on $day"
# `if`, not `&&`: under set -e a folder outside git would end the loop early, and a repo with no commits that day would
# fail the script. Author date, not commit date: a rebase recommits older work with today's commit date.
printf '%s\n' "$lines" | cut -f2 | while IFS= read -r cwd; do
  if [ -d "$cwd" ]; then git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || true; fi
done | sort -u | while IFS= read -r repo; do
  email=$(git -C "$repo" config user.email) || continue
  log=$(git -C "$repo" log --all --since="$day 00:00:00" --author="$email" --date=format-local:%F --format='%ad %h %s' |
    awk -v d="$day" '$1 == d { sub(/^[^ ]+ /, ""); print }' | sort -u -k2) || continue
  if [ -n "$log" ]; then printf '## %s\n%s\n\n' "$repo" "$log"; fi
done
