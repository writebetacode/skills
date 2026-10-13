---
name: release
description: Cut a semver release from conventional commits in two passes, the user editing the changelog between them. Use when asked to release or cut a version, or to go ahead with a prepared release.
---

Two passes; the user edits between them. Uncommitted new top section in `CHANGELOG.md` on a `chore/release-v*` branch: user said go → read [publish.md](publish.md); else ask whether to continue it. None → read [prepare.md](prepare.md). No `origin` → say a release needs one; stop.

Host: `origin` URL contains `github` → GitHub, `gitlab` → GitLab; else whichever of `gh repo view` / `glab repo view` succeeds; both or neither → ask. Read [github.md](github.md) or [gitlab.md](gitlab.md).

Once the version is known, before anything else: tag `v<version>` exists locally or on `origin` (`git ls-remote --tags origin v<version>`) → say so; stop.

Version files: each manifest holding the project's version (`package.json`, `pyproject.toml`, `Cargo.toml`, `.claude-plugin/plugin.json`…) and the lockfile entries mirroring it (`package-lock.json`, `Cargo.lock`). JS: `npm version <version> --no-git-tag-version`. None → changelog only.
