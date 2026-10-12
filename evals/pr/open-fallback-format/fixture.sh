#!/bin/sh
set -e
. "$(dirname "$0")/../../lib/setup.sh"
repo_with_remote main
mkdir -p src
printf "export const SECTIONS = ['Request', 'Answer', 'Not found'];\n" > src/report.js
git add -A && git commit -qm "feat: Add report sections"
git tag -a v0.1.0 -m v0.1.0
publish
git push -q origin v0.1.0
fake_gh
echo "Report sections are hard to scan" > .fake-gh/issue-142
git checkout -qb feat/142-rename-sections
printf "export const SECTIONS = ['Request', 'Answer', 'Gaps'];\n" > src/report.js
git commit -qam "feat(#142)!: Rename the Not found section to Gaps" -m "- Readers skipped \"Not found\"; parsers must match \"Gaps\" now"
printf "# Report\n\nSections: Request, Answer, Gaps.\n" > REPORT.md
git add -A && git commit -qm "docs(#142): Describe the report sections" -m "- New contributors asked what each section means"
