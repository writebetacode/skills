Upgrades: after spec approval, before tasks; never in a spec. Nothing to build → skip. Upgrade-only request → this file alone, no spec: `status.md` `spec: none`; step 1 takes the packages and repos it names. From revise with an `upgrades.md` already: keep it and its numbers, add new ones after the highest, walk only those; none new → `status.md` unchanged.

1. Each dependency the specs' new or changed parts touch, per repo, at the version in use on that repo's base branch, read the way [copy.md](copy.md) reads a spec (fetched, in that repo): `git show origin/<base>:<manifest or lockfile>`: its latest stable (the registry's CLI, e.g. `npm view <pkg> version`, else its releases page) and the changes between the two.
2. Propose one only if it serves this feature: an API it needs, a bug it would hit, a security fix, or a deprecated version its new code would build on. Never unrelated upgrades. None → no file, `status.md` `upgrades: none`, go to tasks.
3. Write `upgrades.md`, numbered like a review, one upgrade per package per repo:

   ````
   # Upgrades: <feature>

   ## 1. <package> <from> → <to> in <repo>
   Why: <what the feature gains>
   Breaking: <each change that hits this repo, path:line | None>
   Ships: in <NN-mr> | own MR before <NN-mr>

   ## Withdrawn
   ### <N>. <heading>
   ````

   Ships: in the MR whose code needs it; breaking changes that reach code the feature doesn't touch → its own MR first.
4. `status.md` `upgrades: draft`. Walk it: each upgrade and where it ships, ≤6 lines; ask to approve. The user withdraws one by moving it under `## Withdrawn`, or says `withdraw <N>`; other changes → edit, walk again. Withdrawing one the specs' Design needs → say they can't be built as written; revise.md. Explicit approval only → `upgrades: approved <date>`.
