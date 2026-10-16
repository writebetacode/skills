#!/bin/sh
# Prints the "## Related repos" entries of a folder's main checkout (default: the current folder; outside a repo, the
# folder itself), from its CLAUDE.md and CLAUDE.local.md, one per line, tab-separated: name, absolute path resolved from
# that checkout, how they relate. An entry with no (path) gets the sibling folder named for the name's last part. Paths
# print whether or not they exist. Exits 2 where main-checkout.sh does (a git folder or a bare repo's own folder).
# Usage: related-repos.sh [path]
root=$("$(dirname "$0")/main-checkout.sh" "${1:-.}" 2>/dev/null)
case $? in
  0) ;;
  1) root=$(cd "${1:-.}" 2>/dev/null && pwd -P) || { echo "no such folder: ${1:-.}" >&2; exit 1; } ;;
  *) echo "no checkout to read Related repos from in ${1:-.}: it's a git folder or a bare repo's own folder" >&2; exit 2 ;;
esac
for f in "$root/CLAUDE.md" "$root/CLAUDE.local.md"; do
  [ -f "$f" ] || continue
  # Each "- name (path): how" line under "## Related repos", up to the next "## " heading.
  awk '/^## /{on = ($0 ~ /^## Related repos[[:space:]]*$/); next}
    on && /^- / { s = substr($0, 3); path = ""; match(s, /^[^ :]+/)
      name = substr(s, 1, RLENGTH); how = substr(s, RLENGTH + 1)
      if (match(how, /^ *\([^)]*\)/)) { path = substr(how, 1, RLENGTH); how = substr(how, RLENGTH + 1); sub(/^ *\(/, "", path); sub(/\)$/, "", path) }
      sub(/[[:space:]]+$/, "", name); sub(/^[[:space:]]*:?[[:space:]]*/, "", how)
      if (path == "") { n = split(name, part, "/"); path = "../" part[n] }
      printf "%s\t%s\t%s\n", name, path, how }' "$f"
done | while IFS="$(printf '\t')" read -r name path how; do
  case $path in /*) ;; "~"/*) path=$HOME/${path#"~"/} ;; *) path=$root/$path ;; esac
  [ -d "$path" ] && path=$(cd "$path" && pwd -P)
  printf '%s\t%s\t%s\n' "$name" "$path" "$how"
done
