#!/bin/sh
# Copies a plan's specs into the repo you're in, each to its path. Its entries: the plan's status.md `spec:` line
# (`<area> <repo>@<commit> <path>`, comma-separated) whose <repo> is this repo's main checkout folder name; the copy:
# the plan's specs/<area>.md. Before writing any, it fetches origin's default branch and checks each copy that differs
# from the file at its path: when the default branch's version (or its absence) matches neither the entry commit's nor
# the copy, someone else changed that spec since the plan copied it, so it writes nothing, names each such path and
# exits 3. Else it writes each copy that differs and prints its path.
# --back: copies each of those files back over its plan copy instead, printing each copy it changed.
# Exit 2: anything else failed.
# Usage: sync-specs.sh [--back] <plan folder>
back=
[ "$1" = --back ] && { back=1; shift; }
[ $# -eq 1 ] || { echo "usage: sync-specs.sh [--back] <plan folder>" >&2; exit 2; }
plan=$1
[ -f "$plan/status.md" ] || { echo "no status.md in $plan" >&2; exit 2; }
top=$(git rev-parse --show-toplevel) || exit 2
main=$("$(dirname "$0")/../../bin/main-checkout.sh") || exit 2
name=$(basename "$main")
# One line per entry for this repo: <area> <commit> <path>
entries=$(sed -n 's/^spec: [^:]*: //p' "$plan/status.md" | tr ',' '\n' |
  awk -v n="$name" 'NF == 3 { split($2, r, "@"); if (r[1] == n) print $1, r[2], $3 }')

if [ -n "$back" ]; then
  while read -r area commit path; do
    [ -n "$area" ] || continue
    cmp -s "$top/$path" "$plan/specs/$area.md" && continue
    cp "$top/$path" "$plan/specs/$area.md" || exit 2
    echo "$plan/specs/$area.md"
  done <<EOF
$entries
EOF
  exit 0
fi

default=$("$(dirname "$0")/../../bin/default-branch.sh") || exit 2
git fetch --quiet origin "$default" || { echo "couldn't fetch $default from origin" >&2; exit 2; }
drift= write=
nl='
'
while read -r area commit path; do
  [ -n "$area" ] || continue
  copy=$plan/specs/$area.md
  [ -f "$copy" ] || { echo "no plan copy: $copy" >&2; exit 2; }
  cmp -s "$copy" "$top/$path" && continue
  git cat-file -e "$commit^{commit}" 2>/dev/null || { echo "$path: no commit $commit here" >&2; exit 2; }
  now=$(git rev-parse --verify --quiet "origin/$default:$path")
  was=$(git rev-parse --verify --quiet "$commit:$path")
  if [ "$now" != "$was" ] && [ "$now" != "$(git hash-object "$copy")" ]; then
    echo "$path: $default changed it since the plan copied it" >&2
    drift=1
  else
    write=$write$area" "$path$nl
  fi
done <<EOF
$entries
EOF
[ -z "$drift" ] || exit 3
while read -r area path; do
  [ -n "$area" ] || continue
  mkdir -p "$(dirname "$top/$path")" && cp "$plan/specs/$area.md" "$top/$path" || exit 2
  echo "$top/$path"
done <<EOF
$write
EOF
