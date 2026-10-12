#!/bin/sh
set -e
. "$(dirname "$0")/../base.sh"
c skills/research/SKILL.md "Cite as path:line." "fix(#123): Cite sources as path:line"
c README.md "Run evals: python3 evals/check.py <model>" "docs: Explain how to run evals"
git checkout -qb feat/commit-skill
c skills/commit/SKILL.md "Commit only what is staged." "feat: Add commit skill"
git checkout -q main
git merge -q --no-ff -m "Merge pull request #3 from acme/feat/commit-skill" feat/commit-skill
git branch -q -D feat/commit-skill
sed "s/## Not found/## Gaps/" skills/research/SKILL.md > s.tmp && mv s.tmp skills/research/SKILL.md
git add -A && git commit -qm "feat!: Rename the Not found section to Gaps"
c .gitignore "node_modules/" "chore: Ignore node_modules"
git push -q origin main
