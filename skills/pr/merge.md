1. `checks`; any failure → report; stop. Fetch; the local branch has commits `origin/<branch>` lacks → report; stop (merging deletes it).
2. Squash unless the caller asks for a merge commit. Squash message: subject = the PR title; body = the ≤5 most important why-bullets from the squashed commits, then the newest squashed `Co-Authored-By` line, copied exactly (none → no trailer).
3. `merge`, deleting the remote branch; refused → report why; stop.
4. Switch to the default branch, pull. Local branch still there → delete it only if `git merge-tree --write-tree <default> <branch>` prints `git rev-parse <default>^{tree}`: `git branch -D` (squash merges defeat `-d`); else keep it, say why.
