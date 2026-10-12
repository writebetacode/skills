#!/bin/sh
set -e
git init -q -b main
git config user.name dev
git config user.email dev@example.com
printf "# Shop skills\n" > README.md
git add -A && git commit -qm "docs: Add README"
git tag -a v0.1.0 -m v0.1.0
git checkout -qb notes-for-node-20
mkdir -p skills/notes
cat > skills/notes/SKILL.md <<'X'
---
name: notes
description: Keep running notes on Node 20 upgrade findings. Use when asked to note something about the upgrade.
---

Append each finding to NOTES.md as one line: date, finding, source.
X
git add -A && git commit -qm "Add notes skill"
git mv skills/notes skills/upgrade-notes
sed 's/^name: notes$/name: upgrade-notes/' skills/upgrade-notes/SKILL.md > skills/upgrade-notes/SKILL.tmp
mv skills/upgrade-notes/SKILL.tmp skills/upgrade-notes/SKILL.md
git add skills/upgrade-notes/SKILL.md
