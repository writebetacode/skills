---
name: release
description: Cut a semver release from conventional commits: changelog and version bump on a release branch for the user to edit, then PR, merge, tag and publish. Use when asked to release or cut a version, or to go ahead with a prepared release.
---

Two passes; the user edits between them. Uncommitted new top section in `CHANGELOG.md` on a `feature-release-v*` branch: user said go → pass 2; else ask whether to continue it. None → pass 1. No `origin` → say a release needs one; stop. Host as the `pr` skill decides it; read [github.md](github.md) or [gitlab.md](gitlab.md).

Pass 1 (never commit or push):

1. Fetch. Commits on the default branch since the last `v*` tag (none → all), oldest first, skipping merge and `chore(release)` commits.
2. Version: last tag bumped by the biggest of: any `!` → major (below 1.0.0: minor); `feat` → minor; `fix`/`perf` → patch. No tag → `0.1.0`. No bump → say nothing to release; stop. Tag `v<version>` exists locally or on `origin` (`git ls-remote --tags origin v<version>`) → say so; stop.
3. `branch` skill: `feature-release-v<version>`.
4. Prepend to `CHANGELOG.md` (new file: under `# Changelog`), empty groups omitted:

   ```
   ## <version> — <today, YYYY-MM-DD>
   **<the release's overall theme, ≤8 words>**
   [<last tag>...v<version>](<compare link>)
   ### Breaking
   - <subject> ([<short hash>](<commit link>))
   ### Features
   ### Fixes
   ### Other
   ```

   Group: `!` → Breaking; else `feat` → Features; `fix`/`perf` → Fixes; rest → Other. No last tag → link `v<version>`'s commits instead of a compare.
5. Set `version` in `.claude-plugin/plugin.json`, if present.
6. Stop: ask the user to review and edit the diff, then say go.

Pass 2:

1. Version = top heading as edited; its tag exists → say so; stop. Set plugin.json and the compare link to match.
2. Commit only `CHANGELOG.md` and plugin.json as `chore(release): v<version>`.
3. `pr` skill: open (Summary: the bold title and compare link), then merge with a merge commit, never squash.
4. Annotated tag `v<version>` on that merge commit; push it.
5. Release named `v<version>`; notes = the section minus its heading.
