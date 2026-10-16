---
name: release
description: Cut a semver release from conventional commits. Run it to draft the changelog, edit that, then run it again with `go`.
disable-model-invocation: true
---

Two passes; the user edits between them. No `origin` → say a release needs one; stop. Under way (a `chore/release-v*` branch or `origin/<default>`, its top `CHANGELOG.md` version untagged): go → read [publish.md](publish.md), on that branch if there is one; else ask whether to continue it. None → read [prepare.md](prepare.md).

Host: `${CLAUDE_PLUGIN_ROOT}/bin/host.sh` (fails → ask). Read [github.md](github.md) or [gitlab.md](gitlab.md).

Once the version is known, before anything else: tag `v<version>` exists locally or on `origin` (`git ls-remote --tags origin v<version>`) → say so; stop.

Version files: each manifest, hidden folders included, holding the project's version (`package.json`, `pyproject.toml`, `Cargo.toml`, `.claude-plugin/plugin.json`…) and the lockfile entries mirroring it (`package-lock.json`, `Cargo.lock`). JS: `npm version <version> --no-git-tag-version`. None → changelog only.
