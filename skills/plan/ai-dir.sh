#!/bin/sh
# Prints the absolute .ai/<area> folder for a folder's repo (default: the current one): in its main checkout, so every
# worktree shares it. --write, passed only right before writing, first makes sure .ai/.gitignore holds *, so git ignores
# all of .ai/, and exits 1 when it can't. Not in a repo: <path>/.ai/<area>. No checkout (a git folder, a bare repo's own
# folder): exits 2 and writes nothing.
# Usage: ai-dir.sh [--write] <area> [path]
write=
[ "$1" = --write ] && { write=1; shift; }
area=${1:?usage: ai-dir.sh [--write] <area> [path]}
root=$("$(dirname "$0")/main-checkout.sh" "${2:-.}")
case $? in
  0) ;;
  1) root=$(cd "${2:-.}" 2>/dev/null && pwd -P) || { echo "no such folder: ${2:-.}" >&2; exit 1; } ;;
  *) echo "won't write .ai inside a git folder; run this from a checkout" >&2; exit 2 ;;
esac
if [ -n "$write" ]; then
  ign=$root/.ai/.gitignore
  if ! grep -qx '\*' "$ign" 2>/dev/null; then
    mkdir -p "$root/.ai" 2>/dev/null
    # Keep * on a line of its own when the file doesn't end in a newline.
    if [ -s "$ign" ] && [ -n "$(tail -c 1 "$ign")" ]; then echo >> "$ign"; fi
    echo '*' >> "$ign" 2>/dev/null
  fi
  grep -qx '\*' "$ign" 2>/dev/null || { echo "can't write $root/.ai/: check its permissions" >&2; exit 1; }
fi
echo "$root/.ai/$area"
