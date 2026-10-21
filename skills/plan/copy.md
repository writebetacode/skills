Starting a spec in the plan's `specs/` (Plan step 4, revise.md):

- Its path in the repo it ships in: the file specifying this area in a folder `<this skill's base directory>/../../bin/specs-dir.sh <repo path>` prints, whatever its name (a dated or per-change spec counts; several → the newest, the others read as sources). None → the first folder printed, named as its specs are (`<area>.md` when named by area, or none yet).
- That path exists on the base → start from its base version, fetched: `git show origin/<base>:<path>` (this repo: here; another: `git -C <its path>`; base: `<this skill's base directory>/../../bin/default-branch.sh <path>`). None → an empty spec.
- Either way, now: `<area> <repo folder name>@<origin/<base> commit> <path>` → `status.md`'s `spec:` line, replacing that area's entry.
