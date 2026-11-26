Pass 1 (never commit or push):

1. `<this skill's base directory>/next-version.sh`: it fetches, then prints the last tag (or `none`) and the next version, then each commit to release, oldest first, with its changelog group. Exit 3 → reply `Nothing to release since <last tag>` with the reason it printed; stop.
2. `branch` skill: `chore/release-v<version>`.
3. Prepend to `CHANGELOG.md` (new file: under `# Changelog`), empty groups omitted:

   ```
   ## <version> — <today, YYYY-MM-DD>

   **<the release's overall theme, ≤8 words>**
   [<last tag>...v<version>](<compare link>)

   ### Breaking

   - <commit subject, verbatim> ([<short hash>](<commit link>))

   ### Features

   ### Fixes

   ### Other
   ```

   Each commit goes under the group the script gave it. No last tag → link `v<version>`'s commits instead of a compare.
4. Set the version files.
5. Stop: ask the user to review and edit the diff, then say go (a later session: `/wbc:release go`).
