Pass 2; a stopped one resumes at its first step not done (commit made, PR open or merged, tag pushed):

1. Version = top heading as edited. Set the version files and the compare link to match.
2. Commit only `CHANGELOG.md` and the version files as `chore(release): v<version>`.
3. `pr` skill: open (Summary: the bold title and compare link), then merge with a merge commit, never squash.
4. Fetch; the merge commit not on `origin/<default>` (`git merge-base --is-ancestor`) → stop. Annotated tag `v<version>` on it; push it.
5. Release named `v<version>`; notes = the section minus its heading.
