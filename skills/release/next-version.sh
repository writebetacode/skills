#!/bin/sh
# Works out the next release from the conventional commits on origin's default branch, fetched with its tags, since
# the last v* tag (none: all of them). Prints `<last tag | none> <next version>`, then each commit to release, oldest
# first, merges and chore(release) ones skipped, as `<group><TAB><full hash><TAB><subject>`. Its group: Breaking (a `!`
# just before the colon, or a BREAKING CHANGE: footer), else Features (feat), Fixes (fix, perf) or Other.
# The version: the last tag bumped by its biggest group: Breaking: major (minor below 1.0.0); Features: minor; Fixes:
# patch. No tag: 0.1.0. Exit 3, saying why: nothing calls for a release. Exit 2: anything else failed.
# Usage: next-version.sh
default=$("$(dirname "$0")/../../bin/default-branch.sh") || exit 2
git fetch --quiet --tags origin "$default" || { echo "couldn't fetch $default from origin" >&2; exit 2; }
head=origin/$default
if tag=$(git describe --tags --abbrev=0 --match 'v*' "$head" 2>/dev/null); then range=$tag..$head; else tag=none range=$head; fi

bump=0 commits= tab=$(printf '\t')
nl='
'
for c in $(git rev-list --reverse --no-merges "$range"); do
  subject=$(git log -1 --format=%s "$c")
  case $subject in 'chore(release)'*) continue ;; esac
  if printf '%s\n' "$subject" | grep -qE '^[A-Za-z]+(\([^)]*\))?!:' ||
    git log -1 --format=%b "$c" | grep -qE '^BREAKING[ -]CHANGE:'; then group=Breaking b=3
  elif printf '%s\n' "$subject" | grep -qE '^feat(\([^)]*\))?:'; then group=Features b=2
  elif printf '%s\n' "$subject" | grep -qE '^(fix|perf)(\([^)]*\))?:'; then group=Fixes b=1
  else group=Other b=0
  fi
  [ "$b" -gt "$bump" ] && bump=$b
  commits=$commits$group$tab$c$tab$subject$nl
done

[ -n "$commits" ] || { echo "Nothing to release since $tag: no commits since it" >&2; exit 3; }
if [ "$tag" = none ]; then
  version=0.1.0
else
  [ "$bump" -gt 0 ] || { echo "Nothing to release since $tag: no feat, fix, perf or breaking commit since it" >&2; exit 3; }
  v=${tag#v} major=${v%%.*} rest=${v#*.} minor=${rest%%.*} patch=${rest#*.}
  patch=${patch%%[!0-9]*}
  case $major.$minor.$patch in *[!0-9.]* | .* | *..* | *.) echo "can't read $tag as v<major>.<minor>.<patch>" >&2; exit 2 ;; esac
  if [ "$bump" -eq 3 ] && [ "$major" -gt 0 ]; then version=$((major + 1)).0.0
  elif [ "$bump" -ge 2 ]; then version=$major.$((minor + 1)).0
  else version=$major.$minor.$((patch + 1))
  fi
fi
printf '%s %s\n' "$tag" "$version"
printf '%s' "$commits"
