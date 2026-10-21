# The .ai folder

Skills keep the files they make for you (plans, research findings, reviews) in one gitignored `.ai/` folder in each repo's main checkout. You always know where to look, and removing a worktree loses nothing. A bare repo, which has no main checkout, is the one exception.

## Why

A repo can have a main checkout and many worktrees, including Claude Code's under `.claude/worktrees/`. Files kept in a worktree vanish with it, unseen by other sessions, so a plan written in one couldn't be built from another.

## What

`plan` keeps each plan in `.ai/plan/<name>/`: its specs, research, tickets, tasks and status. `research` keeps findings in `.ai/research/<name>/`, and `review` keeps one file per pull request in `.ai/reviews/`. `build` works from the plans there. Only specs leave `.ai/`: `build` commits each into the repo's spec folder with its change. Beyond that, skills write only the code and docs you commit, plus `setup`'s gitignored `CLAUDE.local.md`.

## Behaviour

- From any worktree, Claude Code's included, files land in the main checkout's `.ai/`.
- A removed Claude Code worktree's folder still maps to its repo.
- A submodule gets its own `.ai/`, in the superproject's main checkout when it's checked out there, otherwise where it is.
- A bare repo's worktree, or a repo whose git folder lives elsewhere, keeps `.ai/` in its own top folder.
- Outside a repo, `.ai/` goes in the folder itself.
- In a git folder, like `.git` or a bare layout's `.bare`, or a bare repo's own folder, skills refuse to write `.ai/` and say why.
- The first write adds `.ai/.gitignore` holding `*`, so git ignores all of `.ai/`. If that fails, the skill writes it itself and carries on. Looking something up creates nothing.
- In a worktree session, Claude Code refuses file tools in the main checkout, so skills write there with shell commands, which may ask your permission. If that's refused too, the skill says it can't reach the main checkout and stops.
- `setup` writes each repo's `CLAUDE.local.md` in its main checkout the same way.
- `main-checkout.sh [path]` prints a folder's main checkout, and `ai-dir.sh [--write] <area> [path]` prints its `.ai/<area>/` folder. `--write` first makes sure the ignore file exists. Both fail where there's no checkout to write in.

## Sketch

```
$ bin/ai-dir.sh --write plan ~/code/shop/.claude/worktrees/fix-cart
/Users/you/code/shop/.ai/plan

~/code/shop/.ai/
  .gitignore                     *
  plan/empty-cart-total/         status.md, specs/, research/, tickets/, tasks/
  research/flaky-cart-test/      findings.md
  reviews/142.md
```

## Decisions

- **`.ai/` lives in the main checkout, even when only a shell can reach it**: never the worktree's own. Why: one place to look per repo, and worktrees come and go, taking any copy with them.
- **A bare repo falls back to the current checkout**: Why: there's no main checkout, and `.ai/` must never land in a git folder.
- **Outside a repo, `.ai/` goes in the folder itself**: Why: skills plan and research in folders that aren't repos too.
- **Only a write adds the ignore file**: Why: a lookup must leave the repo as it was.
- **Nothing under `.claude/` or `.git/`**: except code in a Claude Code worktree. Why: Claude Code protects them, so every write there prompts or is denied.
- **Only specs leave `.ai/`**: Why: a spec is the team's record of what an area does, and `review` checks pull requests against it. Plans, findings and reviews are your working files.

## Out of scope

- The throwaway worktrees `review` and `research` check code out into.
- Where a repo keeps its specs (the shared scripts spec).
- A refused-write fallback in `daily`, which writes no `.ai/` files itself.
