# Changelog

## 0.2.0 — 2026-10-13

**Safer branch cleanup and more reliable releases**
[v0.1.1...v0.2.0](https://github.com/writebetacode/skills/compare/v0.1.1...v0.2.0)

### Features

- feat: Delete only fully merged branches and tag only merged releases ([55c30e4](https://github.com/writebetacode/skills/commit/55c30e46d27e2bb1054436d86c8411fa311c43a0))

### Fixes

- fix: Bump hidden manifests and keep commit subjects whole in releases ([3e148d0](https://github.com/writebetacode/skills/commit/3e148d062934a799e50a4d98101e0791b949b251))
- fix: Accept clear asks without a question mark in eval graders ([9c246c9](https://github.com/writebetacode/skills/commit/9c246c930c33bd45dd22652ed74b22c5d34be562))

### Other

- chore: Accept "nothing that needs a release" and store new eval scores ([0422b19](https://github.com/writebetacode/skills/commit/0422b19998d40aa05516f3520652bb659c753980))

## 0.1.1 — 2026-10-13

**Fresher branch bases and cheaper release evals**
[v0.1.0...v0.1.1](https://github.com/writebetacode/skills/compare/v0.1.0...v0.1.1)

### Fixes

- fix: Write lint-clean changelogs and lint shell-written Markdown ([a1c8650](https://github.com/writebetacode/skills/commit/a1c865062bc6a16ae249565b818e5ef78bc389fb))
- fix: Base work on the remote default branch and check release tags remotely ([a3ffdd4](https://github.com/writebetacode/skills/commit/a3ffdd4f8479e42f1cdfd43a7bab8233d3c9846a))

### Other

- chore: Skip the macOS git shim for fetch and push in eval fixtures ([ec22c59](https://github.com/writebetacode/skills/commit/ec22c59fbeb0bcf9f2d94d5c71df4ab01adf7d74))
- docs: Make skill groups stand out from skills in the README ([3e4ceb7](https://github.com/writebetacode/skills/commit/3e4ceb753dcef390752a5e29fddc8205a7a10590))
- chore: Run release evals only for skills changed since the last release ([81a5e0c](https://github.com/writebetacode/skills/commit/81a5e0cc8bea4cc11dc6efc9001337d92590e338))

## 0.1.0 — 2026-10-13

**First cut of the wbc skills plugin**
[v0.1.0](https://github.com/writebetacode/skills/commits/v0.1.0)

### Features

- feat: Add the wbc plugin with seven productivity skills and evals ([0478282](https://github.com/writebetacode/skills/commit/04782823a66ffcfa9011476bc8bfe512b6e32b30))
- feat: Add ticket skill for GitHub, GitLab and Jira ([cbdece1](https://github.com/writebetacode/skills/commit/cbdece17381fce7e3e036e77df65f70969b132fb))
- feat: Add review skill for GitHub and GitLab PRs ([0631190](https://github.com/writebetacode/skills/commit/063119025786a1effbd43e12d8bae7bd205715e4))
- feat: Add sdlc-plan and sdlc-build skills ([8a07619](https://github.com/writebetacode/skills/commit/8a07619f83e1539fe4568e3215e3bfbb42b0b37d))
- feat: Add voice skill for text people read ([6d7209e](https://github.com/writebetacode/skills/commit/6d7209e1ceb8ce312e118e485a6369ab02ff8129))
- feat: Load skill branches on demand and make paid evals opt-in ([350f0c4](https://github.com/writebetacode/skills/commit/350f0c4ee65011f872111d2c2bee4ccb6eed9b45))

### Fixes

- fix: Stop releases whose version tag already exists ([afcb2ca](https://github.com/writebetacode/skills/commit/afcb2cadf01cc79b9dcc79a1077224e6603e871a))
- fix: Leave skill-fired checks out of the eval Δ ([cb86156](https://github.com/writebetacode/skills/commit/cb8615619e227a136eec4b637ad16bc7c872bde2))
- fix: Stop re-posting review findings and move skills to skills/ ([a9f5485](https://github.com/writebetacode/skills/commit/a9f5485d3be38252b440a42a76359b007beafcc6))

### Other

- docs: Add README with install steps ([997a8d7](https://github.com/writebetacode/skills/commit/997a8d7e91fdfbeff0af50abd78d62a1bd0fb4f5))
- chore: Run markdownlint on Markdown Claude edits ([50ad1cd](https://github.com/writebetacode/skills/commit/50ad1cd97ce6117e403defff819eb5b0d60ed450))
