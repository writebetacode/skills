#!/bin/sh
set -e
export GIT_AUTHOR_DATE="2026-10-01T12:00:00Z" GIT_COMMITTER_DATE="2026-10-01T12:00:00Z"
git init -q --bare -b trunk .remote.git
git init -q -b trunk
git config user.name dev
git config user.email dev@example.com
echo ".remote.git/" >> .git/info/exclude
printf "export function login(user, password) {\n  return checkPassword(user, password);\n}\n" > login.js
git add -A && git commit -qm "feat: Add login"
git remote add origin "$PWD/.remote.git"
git push -q -u origin trunk
# A teammate pushes to trunk; local trunk is now behind.
T=$(mktemp -d)
git clone -q .remote.git "$T/c"
(cd "$T/c" && git config user.name ann && git config user.email ann@example.com && printf "# Shop\n" > README.md && git add -A && git commit -qm "docs: Add README" && git push -q origin trunk)
rm -rf "$T"
# We're mid-work on another branch with an uncommitted edit.
git checkout -qb feat/abc-99-search
printf "export function search(q) {\n  return [];\n}\n" > search.js
git add search.js && git commit -qm "feat(ABC-99): Add search"
printf "// TODO: rate limit\n" >> login.js
