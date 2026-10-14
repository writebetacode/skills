---
name: release
description: Cut a semver release from conventional commits. Run it to draft the changelog, edit that, then run it again with `go`.
disable-model-invocation: true
---

Two passes; the user edits between them. No `origin` → say a release needs one; stop. A release under way, either a `chore/release-v*` branch with a new top section in `CHANGELOG.md` (uncommitted, or committed but not merged; switch to it) or a top version in `origin/<default>`'s `CHANGELOG.md` with no `v<version>` tag: user said go → read [publish.md](publish.md); else ask whether to continue it. None → read [prepare.md](prepare.md).

Host: `${CLAUDE_SKILL_DIR}/../pr/host.sh` (fails → ask). Read [github.md](github.md) or [gitlab.md](gitlab.md).

Once the version is known, before anything else: tag `v<version>` exists locally or on `origin` (`git ls-remote --tags origin v<version>`) → say so; stop.

Version files: each manifest, hidden folders included, holding the project's version (`package.json`, `pyproject.toml`, `Cargo.toml`, `.claude-plugin/plugin.json`…) and the lockfile entries mirroring it (`package-lock.json`, `Cargo.lock`). JS: `npm version <version> --no-git-tag-version`. None → changelog only.
