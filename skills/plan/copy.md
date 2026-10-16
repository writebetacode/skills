Starting a spec in the plan's `specs/` (Plan step 4, revise.md):

- Its area has a spec in the repo it ships in → start from its base version there, fetched: `git show origin/<base>:docs/specs/<area>.md` (this repo: here; another: `git -C <its path>`; base: `<this skill's base directory>/../../bin/default-branch.sh <path>`). None → an empty spec.
- Either way, now: `<repo folder name>@<origin/<base> commit> docs/specs/<area>.md` → `status.md`'s `spec:` line, replacing that repo and path's entry.
