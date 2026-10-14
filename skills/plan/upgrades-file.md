Upgrades: after spec approval, before tasks; never in the spec. Nothing to build → skip. From revise with an `upgrades.md` already: keep it and its numbers, add new ones after the highest, walk only those; none new → `status.md` unchanged.

1. Each dependency the spec's Design touches, at the version in use (`research/`): its latest stable (the registry's CLI, e.g. `npm view <pkg> version`, else its releases page) and the changes between the two.
2. Propose one only if it serves this feature: an API it needs, a bug it would hit, a security fix, or a deprecated version its new code would build on. Never unrelated upgrades. None → no file, `status.md` `upgrades: none`, go to tasks.
3. Write `upgrades.md`, numbered like a review:

   ````
   # Upgrades: <feature>

   ## 1. <package> <from> → <to>
   Why: <what the feature gains>
   Breaking: <each change that hits this repo, path:line | None>
   Ships: in <NN-mr> | own MR before <NN-mr>

   ## Withdrawn
   ### <N>. <heading>
   ````

   Ships: in the MR whose code needs it; breaking changes that reach code the feature doesn't touch → its own MR first.
4. `status.md` `upgrades: draft`. Walk it: each upgrade and where it ships, ≤6 lines; ask to approve. The user withdraws one by moving it under `## Withdrawn`, or says `withdraw <N>`; other changes → edit, walk again. Withdrawing one the spec's Design needs → say it can't be built as written; revise.md. Explicit approval only → `upgrades: approved <date>`.
