# Changelog

## 0.6.1 — 2026-10-18

**Lint-clean Markdown from every skill, in any repo**
[v0.6.0...v0.6.1](https://github.com/writebetacode/skills/compare/v0.6.0...v0.6.1)

### Fixes

- fix: Lint every Markdown file the skills write ([16bb627](https://github.com/writebetacode/skills/commit/16bb6279de92ec87b887225b29b515fd5c8de115))

## 0.6.0 — 2026-10-16

**Leaner skills, and research splits from plan**
[v0.5.0...v0.6.0](https://github.com/writebetacode/skills/compare/v0.5.0...v0.6.0)

### Breaking

- feat!: Slim the skills back to one domain each, with research split from plan (#41) ([e7e2018](https://github.com/writebetacode/skills/commit/e7e201885ff09c97ac89ca22014e127ace2bd023))

### Features

- feat: Build fixes the docs it makes untrue; daily archives finished reviews ([083e766](https://github.com/writebetacode/skills/commit/083e766eade5c8ed361df70625da3834a570bcbb))

## 0.5.0 — 2026-10-15

**Living specs, smarter daily, plans shared across worktrees**
[v0.4.0...v0.5.0](https://github.com/writebetacode/skills/compare/v0.4.0...v0.5.0)

### Breaking

- feat!: Close workflow gaps across plan, build, review, ticket, daily and setup (#38) ([246c8d8](https://github.com/writebetacode/skills/commit/246c8d88e82846fd1edf267d7a1e182e414eb64e))

## 0.4.0 — 2026-10-14

**Setup and daily skills, and sturdier plans**
[v0.3.0...v0.4.0](https://github.com/writebetacode/skills/compare/v0.3.0...v0.4.0)

### Breaking

- feat!: Fold research into plan, drop paid evals, call release and recap by name ([a8dd0f7](https://github.com/writebetacode/skills/commit/a8dd0f71d0b46063f88ea1230ec51906ec757f17))
- feat!: Replace recap with daily to plan your morning and recap your day (#32) ([dae3048](https://github.com/writebetacode/skills/commit/dae30489146e84d13c9731c9f33a0db4c42ee9c9))

### Features

- feat: Add setup to check CLIs, link related repos and list debug tools (#31) ([afa060d](https://github.com/writebetacode/skills/commit/afa060ddf9f486ac128bc4ea6db49f341e92f3da))
- feat: Propose an upgrade path in plan before tasks are written (#33) ([2e9a5cc](https://github.com/writebetacode/skills/commit/2e9a5cc95b3b71eb5c808032ea9c6e760eaa784e))
- feat: Check each spec with a fresh agent before plan walks you through it (#34) ([77c4a05](https://github.com/writebetacode/skills/commit/77c4a0528345a3e39098cce8f4d9f274e4903998))

### Fixes

- fix: Link daily's Jira tickets only to the site you're logged in to (#35) ([3b5999d](https://github.com/writebetacode/skills/commit/3b5999d9d1c7bcd18cc50b868e77c70b93c7f62f))
- fix: Cover edge cases where skills lost work, stalled or misread state (#36) ([fd43e79](https://github.com/writebetacode/skills/commit/fd43e79edc409e3932fed7fb77958e2618b6cf12))

## 0.3.0 — 2026-10-14

**Debugging joins plan, and build lands its PRs**
[v0.2.0...v0.3.0](https://github.com/writebetacode/skills/compare/v0.2.0...v0.3.0)

### Breaking

- feat!: Merge debug into plan, let build land PRs and add recap ([57642e2](https://github.com/writebetacode/skills/commit/57642e259834318a01d51e3069b4403e6df13b78))

### Features

- feat: Recheck review findings with a read-only checker agent ([68ca826](https://github.com/writebetacode/skills/commit/68ca826a29728a76c0ebf162037832854c714273))
- feat: Add debug skill and let anyone call same-page ([43e6378](https://github.com/writebetacode/skills/commit/43e6378be2abab5fab88851e0c183360f235a8d6))

### Fixes

- fix: Send every nested review finding to the checker and document agents ([5284ee8](https://github.com/writebetacode/skills/commit/5284ee86824921c3e33ef989910421975301b982))
- fix: Prune merged branch refs and clean up stopped eval runs ([e010b33](https://github.com/writebetacode/skills/commit/e010b3315a524acd7e14150e7e0a538e9489485a))
- fix: Keep recap commits whole and make the eval suite catch what it missed (#28) ([57622cf](https://github.com/writebetacode/skills/commit/57622cf35d0b65222ade5222c88264f960a45caa))

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
