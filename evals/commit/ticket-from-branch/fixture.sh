#!/bin/sh
set -e
git init -q -b main
git config user.name dev
git config user.email dev@example.com
mkdir -p skills/research
cat > skills/research/SKILL.md <<'X'
---
name: research
description: Investigate a question; return a cited report. Use when asked to look into something.
---

Output only the report: ## Request, ## Answer, ## Not found.
X
git add -A && git commit -qm "feat: Add research skill"
git tag -a v0.1.0 -m v0.1.0
git checkout -qb feat/abc-142-rename-research
git mv skills/research skills/investigate
sed 's/^name: research$/name: investigate/' skills/investigate/SKILL.md > skills/investigate/SKILL.tmp
mv skills/investigate/SKILL.tmp skills/investigate/SKILL.md
git add skills/investigate/SKILL.md
echo "scratch notes" > notes.txt
