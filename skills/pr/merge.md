1. `checks`; any failure → report; stop.
2. Squash unless the caller asks for a merge commit. Squash message: subject = the PR title; body = the ≤5 most important why-bullets from the squashed commits, then the newest squashed `Co-Authored-By` line, copied exactly (none → no trailer).
3. `merge`, deleting the remote branch; refused → report why; stop.
4. Switch to the default branch, pull, delete the local branch if it's still there.
