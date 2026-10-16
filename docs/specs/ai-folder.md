# The .ai folder

Skills keep the files they make for you (plans, findings, reviews) in one gitignored `.ai/` folder in each repo's main checkout, never inside a linked worktree, so you always know where to look and removing a worktree loses nothing. A bare repo, which has no main checkout, is the one exception.

## Context

A repo can have a main checkout and any number of linked worktrees, including the ones Claude Code makes for worktree sessions under `<checkout>/.claude/worktrees/`. `git worktree list` names the main checkout first, except in a bare repo, which has none. A common bare layout keeps a folder like `~/code/shop` holding the bare git folder `.bare/`, a `.git` file pointing to it, and the worktrees (`~/code/shop/main`, …) side by side. When Claude Code isolates a session in a worktree, it refuses that session's file tools on paths in the main checkout; a plain shell write there goes through your permission settings and, when it's on, the sandbox, but a compound command it can't verify is refused.

In the repos they work on, skills keep their working files only under `.ai/<area>/` (`plan`, `research`, `reviews`), with `.ai/.gitignore` holding `*`. The other files they write in a repo are ones you commit (code, specs) and `setup`'s `CLAUDE.local.md`, and they never write under `.claude/` or `.git/`, which Claude Code protects, apart from code in a Claude Code worktree. Shared scripts live in the plugin's `bin/` (the bin spec).

## Scope

In: where `.ai/` lives; `main-checkout.sh` and `ai-dir.sh`; writing `.ai/` from a worktree session; the AGENTS.md rule on where skills write; the README's mentions of `.ai/`.
Out: the throwaway code worktrees `review` and `research` make; a refused-write line in `daily`, which writes no `.ai/` files itself.

## Behaviour

```gherkin
Scenario Outline: Files land in the repo's main checkout
  Given a session in <folder>, <which>
  When it makes a plan
  Then the plan lands under <lands>, never inside a git folder or .claude

  Examples:
    | folder                            | which                                   | lands                      |
    | ~/code/shop-cart                  | a linked worktree of ~/code/shop        | ~/code/shop/.ai/plan/      |
    | ~/code/shop/.claude/worktrees/fix | a Claude Code worktree of ~/code/shop   | ~/code/shop/.ai/plan/      |
    | ~/code/shop/main                  | a worktree of the bare repo ~/code/shop | ~/code/shop/main/.ai/plan/ |
    | ~/code/shop-cart/lib              | a submodule in a linked worktree of shop | ~/code/shop/lib/.ai/plan/  |
    | ~/notes                           | in no repo                              | ~/notes/.ai/plan/          |

Scenario: A removed Claude Code worktree still maps to its repo
  Given a session ran in ~/code/shop/.claude/worktrees/fix-cart, since removed
  When a skill asks which repo that folder belongs to
  Then the answer is ~/code/shop

Scenario: Looking up .ai changes nothing
  Given ~/code/web has no .ai folder
  When a skill looks there for a review file
  Then no .ai folder or ignore file is created

Scenario: Nothing is written where a bare repo has no checkout
  When a skill runs in a bare git folder, like ~/code/shop/.bare, or in the bare layout's ~/code/shop
  Then it refuses to write .ai there and says why

Scenario: A worktree session writes .ai with shell commands
  Given a session Claude Code isolates in ~/code/shop/.claude/worktrees/fix-cart
  When Claude Code refuses to write a plan's file into ~/code/shop
  Then the skill writes it under ~/code/shop/.ai/plan/ with shell commands, never under the worktree's .ai/
  And if the shell write is refused too, it says it can't reach the main checkout and stops
```

## Design

`bin/main-checkout.sh [path]` prints a folder's main checkout. A folder under `<checkout>/.claude/worktrees/<name>/`, there or removed, maps as the same folder in `<checkout>` does; a submodule maps to its own checkout, and one inside a linked worktree maps to the same submodule in the superproject's main checkout when it's checked out there, else to itself; a bare repo's worktree maps to itself. A git folder or a bare repo's own folder exits 2; a folder in no repo exits 1.

`bin/ai-dir.sh [--write] <area> [path]` prints `<main checkout>/.ai/<area>`, or `<path>/.ai/<area>` outside a repo. Where `main-checkout.sh` exits 2, it exits 2 too, saying why, and the skill writes nothing. `--write`, passed only right before writing, first makes sure `.ai/.gitignore` holds `*`. When it can't, it exits 1 with a message telling the caller to write that file holding `*` and run it again; the caller acts on this failure rather than just reporting it.

**A refused write.** `plan`, `research`, `build` and `review` each carry one short line, and `setup` a shorter one for `CLAUDE.local.md` with no folder or `ai-dir.sh` step: when, in a worktree session, Edit or Write on a main-checkout `.ai/` file is refused, make its folder, then write the file's whole text with a quoted heredoc whose end marker matches no line of it, each a plain command on its own, since a compound one is refused; refused again, or the `ai-dir.sh` rerun fails → say it can't reach the main checkout and stop. Never the worktree's copy.

The AGENTS.md rule on where skills write names `ai-dir.sh`, `main-checkout.sh` and the refused-write line. The README says plans, findings and reviews stay in the repo's main folder, shared by every worktree.

Testing: the repo's check script and markdownlint; running both scripts from a main checkout, a linked worktree, a Claude Code worktree (live and removed), a bare repo's worktree and own folder, a submodule, a submodule inside a linked worktree, and outside a repo.

## Decisions

- **`.ai/` lives in the main checkout**: Why: one place to look per repo, and worktrees come and go. Not per worktree.
- **Main checkout from `git worktree list`**: Why: it names the main checkout first and marks a bare repo, and a submodule's first entry leads to its own checkout. Not the parent of the git common folder: wrong for submodules and `--separate-git-dir`, and blind to bare repos.
- **A bare repo falls back to the current checkout**: Why: there's no main checkout, and `.ai/` must never land in a git folder.
- **Outside a repo, `.ai/` goes in the folder itself**: Why: skills plan and research in folders that aren't repos too. Not refusing.
- **The refused-write line is a copy in each skill that writes there**: Why: it reacts to a refusal partway through the skill's work, which no script can catch. Not a shared write script: each skill would still need the line saying when to use it.
- **The ignore file is written only before a write**: Why: a lookup must leave the repo as it was.
