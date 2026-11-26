Pass 2; a stopped one resumes at its first step not done (commit made, PR open or merged, tag pushed):

1. Version = top heading as edited. Set the version files and the compare link to match.
2. Commit only `CHANGELOG.md` and the version files as `chore(release): v<version>`.
3. `pr` skill: open, titled `chore(release): v<version>` (Summary: the bold title and compare link), then merge with a merge commit; refused because the repo allows only squash merges → merge again, squashing. Either way the release commit lands as `chore(release): v<version>`: the next release skips commits by that subject, and under any other it'd list this one under Other.
4. Fetch; the merge commit not on `origin/<default>` (`git merge-base --is-ancestor`) → stop. Annotated tag `v<version>` on it; push it.
5. Release named `v<version>`; notes = the section minus its heading.
