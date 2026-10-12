#!/bin/sh
set -e
. "$(dirname "$0")/../base.sh"
c README.md "Run evals: python3 evals/check.py <model>" "docs: Explain how to run evals"
c .gitignore "node_modules/" "chore: Ignore node_modules"
c tests/report.test.sh "grep -q \"## Request\" out.md" "test: Cover report sections"
git push -q origin main
