# Sourced by release fixtures: shop-skills released at v0.1.0 (tag on origin), fake gh, helper `c`.
. "$(dirname "$0")/../../lib/setup.sh"
repo_with_remote main
mkdir -p .claude-plugin skills/research
printf '{\n  "name": "shop-skills",\n  "version": "0.1.0",\n  "skills": ["./skills/"]\n}\n' > .claude-plugin/plugin.json
printf '{\n  "name": "shop-skills",\n  "version": "0.1.0",\n  "private": true\n}\n' > package.json
printf '{\n  "name": "shop-skills",\n  "version": "0.1.0",\n  "lockfileVersion": 3,\n  "requires": true,\n  "packages": {\n    "": {\n      "name": "shop-skills",\n      "version": "0.1.0"\n    }\n  }\n}\n' > package-lock.json
printf -- "---\nname: research\ndescription: Investigate a question; return a cited report. Use when asked to look into something.\n---\n\nOutput only the report: ## Request, ## Answer, ## Not found.\n" > skills/research/SKILL.md
printf "# Changelog\n\n## 0.1.0 — 2026-09-01\n**First cut of the research skill**\n[v0.1.0](https://github.com/acme/shop/commits/v0.1.0)\n### Features\n- feat: Add research skill ([3f2a1b0](https://github.com/acme/shop/commit/3f2a1b0c4d5e6f708192a3b4c5d6e7f8091a2b3c))\n" > CHANGELOG.md
git add -A && git commit -qm "chore(release): v0.1.0"
git tag -a v0.1.0 -m v0.1.0
publish
git push -q origin v0.1.0
fake_gh
printf '%s\n' "feat(ABC-12): Add search filters" "fix(#15): Round cart totals to cents" > .fake-gh/merged-titles
# c <file> <line to append> <commit message>
c() { mkdir -p "$(dirname "$1")"; printf "%s\n" "$2" >> "$1"; git add -A; git commit -qm "$3"; }
