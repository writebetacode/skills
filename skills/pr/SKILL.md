---
name: pr
description: Open or update, mark draft or ready, or merge the GitHub pull request or GitLab merge request for the current branch. Use when asked to open, update, draft, ready or merge a PR/MR, or when another skill needs one.
---

Host: `origin` URL contains `github` → GitHub, `gitlab` → GitLab; else whichever of `gh repo view` / `glab repo view` succeeds; both or neither → ask. Read [github.md](github.md) or [gitlab.md](gitlab.md) and run remote commands only from its table. Say "pull request" or "merge request" to match. Base: the caller's (stacking), else the default branch: `git remote set-head origin -a`, then `origin/HEAD`; never assume `main`.

**Open** (the branch already has one → update it):

1. Push: `git push -u origin <branch>` unless the remote has the same SHA. Never force; rejected → report; stop.
2. Invoke the `voice` skill.
3. Title: match the style of the last 20 merged titles (`merged`): ticket or not and where, casing, prefix. No clear style → commit-subject form: most significant type among the branch's commits, ticket from the branch, `!` if any commit has one: ✓ `fix(#142): Stop double-charging empty carts`.
4. Body: fill the repo's PR/MR template if it has one, else:

   ```
   ## Tickets
   - <ABC-123 | [#142](<url>) <issue title> | N/A>
   ## Summary
   <≤2 sentences: what changed and why>
   ## Merge order
   1. <MR URL> <title> <(this) on this one>
   ## Changes
   - `<file>`: <one line>
   ```

   Merge order only when the caller gives one (MRs that ship together, across repos too). Either way between `<!-- pr-body:start -->` and `<!-- pr-body:end -->`. ≤10 Changes bullets; more → one per group. Link an issue only after `issue` finds it. Write the body to a temp file outside the repo.
5. New → `create`, assigned to the user; show the URL. Existing → replace only between the markers (none → insert at the top), keep the rest byte-for-byte, `edit-body`; `edit-title` if the title no longer fits.

**Draft/ready**: only when asked; already so → say so.

**Merge**:

1. `checks`; any failure → report; stop.
2. Squash unless the caller asks for a merge commit. Squash message: subject = the PR title; body = the ≤5 most important why-bullets from the squashed commits, then the newest squashed `Co-Authored-By` line, copied exactly (none → no trailer).
3. `merge`, deleting the remote branch; refused → report why; stop.
4. Switch to the default branch, pull, delete the local branch if it's still there.

No AI attribution in titles or descriptions.
