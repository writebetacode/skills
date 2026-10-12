---
name: branch
description: Create a git branch off the up-to-date default branch, named by convention or as given. Use when asked to start or create a branch, or when another skill needs one.
---

1. Default branch: `git remote set-head origin -a`, then `git symbolic-ref --short refs/remotes/origin/HEAD` minus `origin/`; never assume `main`. Fetch it. No `origin` → the local default branch.
2. Name: as given; else `<type>/<ticket>-<short-name>`, lowercase, short name 2–4 words, type from the request (`feat`, `fix`, `chore`…), ticket only if the request names one:
   - ✓ `feat/abc-123-login-lockout`, `fix/142-null-cart-total`, `docs/eval-guide`
3. Name exists locally or on `origin` → stop; ask what to do.
4. `git switch --no-track -c <name> origin/<default>`; uncommitted changes come along. Conflict → report it; never stash or discard.
