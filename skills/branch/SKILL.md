---
name: branch
description: Create a git branch off the up-to-date default branch, named by convention or as given. Use when asked to start or create a branch, or when another skill needs one.
---

1. Base: `origin/<default>`, fetched, even when the caller names the default: `${CLAUDE_SKILL_DIR}/default-branch.sh`; never assume `main`. Another branch the caller gives (stacking) → it: local if it exists, else fetched `origin/<it>`. No `origin` → local branches.
2. Name: as given; else `<type>/<ticket>-<short-name>`, lowercase, short name 2–4 words, type from the request (`feat`, `fix`, `chore`…), ticket only if the request names one:
   - ✓ `feat/abc-123-login-lockout`, `fix/142-null-cart-total`, `docs/eval-guide`
3. Name exists locally or on `origin` → stop; ask what to do.
4. `git switch --no-track -c <name> <base>`; uncommitted changes come along. Conflict → report it; never stash or discard.
