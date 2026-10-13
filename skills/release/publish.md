Pass 2:

1. Version = top heading as edited. Set the version files and the compare link to match.
2. Commit only `CHANGELOG.md` and the version files as `chore(release): v<version>`.
3. `pr` skill: open (Summary: the bold title and compare link), then merge with a merge commit, never squash.
4. Annotated tag `v<version>` on that merge commit; push it.
5. Release named `v<version>`; notes = the section minus its heading.
