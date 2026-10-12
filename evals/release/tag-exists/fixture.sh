#!/bin/sh
set -e
. "$(dirname "$0")/../base.sh"
c skills/commit/SKILL.md "Commit only what is staged." "feat: Add commit skill"
git push -q origin main
git checkout -qb feature-release-v0.2.0
# Pass 1 ran; the user then edited the new heading to an already-tagged version.
{ printf '# Changelog\n\n## 0.1.0 — 2026-10-12\n**Commits get their own skill**\n[v0.1.0...v0.2.0](https://github.com/acme/shop/compare/v0.1.0...v0.2.0)\n### Features\n- feat: Add commit skill ([%s](https://github.com/acme/shop/commit/%s))\n\n' "$(git rev-parse --short HEAD)" "$(git rev-parse HEAD)"; tail -n +3 CHANGELOG.md; } > c.tmp && mv c.tmp CHANGELOG.md
sed 's/"version": "0.1.0"/"version": "0.2.0"/' .claude-plugin/plugin.json > p.tmp && mv p.tmp .claude-plugin/plugin.json
