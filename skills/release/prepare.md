Pass 1 (never commit or push):

1. Fetch. Commits on the default branch since the last `v*` tag (none → all), oldest first, skipping merge and `chore(release)` commits.
2. Version: last tag bumped by the biggest of: any `!` → major (below 1.0.0: minor); `feat` → minor; `fix`/`perf` → patch. No tag → `0.1.0`. No bump → say nothing to release; stop. Tag `v<version>` exists locally or on `origin` (`git ls-remote --tags origin v<version>`) → say so; stop.
3. `branch` skill: `chore/release-v<version>`.
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

   Group: `!` → Breaking; else `feat` → Features; `fix`/`perf` → Fixes; rest → Other. No last tag → link `v<version>`'s commits instead of a compare. Theme: `voice` skill (once per session).
5. Set the version files.
6. Stop: ask the user to review and edit the diff, then say go.
