# The .ai folder

Skills keep the files they make for you (plans, findings, reviews) in one gitignored `.ai/` folder in each repo's main checkout, never inside a linked worktree, so you always know where to look and removing a worktree loses nothing. A bare repo, which has no main checkout, is the one exception.

## Context

A repo can have a main checkout and any number of linked worktrees, including the ones Claude Code makes for worktree sessions under `<checkout>/.claude/worktrees/`. A bare repo has no main checkout. A common bare layout keeps a folder like `~/code/shop` holding the bare git folder `.bare/`, a `.git` file pointing to it, and the worktrees (`~/code/shop/main`, …) side by side. When Claude Code isolates a session in a worktree, it refuses that session's file tools on paths in the main checkout, while a plain shell write there goes through your permission settings and, when it's on, the sandbox.

In the repos they work on, skills keep their working files only under `.ai/<area>/` (`plan`, `research`, `reviews`), with `.ai/.gitignore` holding `*`. The other files they write in a repo are ones you commit (code, specs) and `setup`'s `CLAUDE.local.md`, and they never write under `.claude/` or `.git/`, which Claude Code protects, apart from code in a Claude Code worktree.

## Scope

In: where `.ai/` lives; which repo a folder belongs to; writing into the main checkout from a worktree session, for `.ai/` and for `setup`'s `CLAUDE.local.md`; the AGENTS.md rule on where skills write; the README's mentions of `.ai/` (plans, findings and reviews stay in the repo's main folder, shared by every worktree).
Out: the throwaway code worktrees `review` and `research` make; a refused-write fallback in `daily`, which writes no `.ai/` files itself.

## Behaviour

```gherkin
Scenario Outline: Files land in the repo's main checkout
  Given a session in <folder>, <which>
  When it makes a plan
  Then the plan lands under <lands>, never inside a git folder or .claude

  Examples:
    | folder                            | which                                                     | lands                             |
    | ~/code/shop-cart                  | a linked worktree of ~/code/shop                          | ~/code/shop/.ai/plan/             |
    | ~/code/shop/.claude/worktrees/fix | a Claude Code worktree of ~/code/shop                     | ~/code/shop/.ai/plan/             |
    | ~/code/shop/main                  | a worktree of the bare repo ~/code/shop                   | ~/code/shop/main/.ai/plan/        |
    | ~/code/shop/lib                   | a submodule of ~/code/shop                                | ~/code/shop/lib/.ai/plan/         |
    | ~/code/shop-cart/lib              | a submodule in a linked worktree of shop                  | ~/code/shop/lib/.ai/plan/         |
    | ~/code/shop-cart/vendor           | a submodule in a linked worktree, not checked out in shop | ~/code/shop-cart/vendor/.ai/plan/ |
    | ~/code/blog                       | a repo whose git folder lives somewhere else              | ~/code/blog/.ai/plan/             |
    | ~/notes                           | in no repo                                                | ~/notes/.ai/plan/                 |

Scenario: A removed Claude Code worktree still maps to its repo
  Given a session ran in ~/code/shop/.claude/worktrees/fix-cart, since removed
  When a skill asks which repo that folder belongs to
  Then the answer is ~/code/shop

Scenario: Git ignores everything in .ai
  Given ~/code/web has no .ai folder
  When a skill writes its first review file there
  Then .ai/.gitignore holding * is written first
  And if writing it fails, the skill writes it itself, then carries on

Scenario: Looking up .ai changes nothing
  Given ~/code/web has no .ai folder
  When a skill looks there for a review file
  Then no .ai folder or ignore file is created

Scenario: Nothing is written where there's no checkout
  When a skill runs in a git folder, like ~/code/shop/.git or ~/code/shop/.bare, or in the bare layout's ~/code/shop
  Then it refuses to write .ai there and says why

Scenario: A worktree session writes .ai with shell commands
  Given a session Claude Code isolates in ~/code/shop/.claude/worktrees/fix-cart
  When Claude Code refuses to write a plan's file, or .ai/.gitignore, into ~/code/shop
  Then the skill writes it under ~/code/shop/.ai/ with shell commands, never under the worktree's .ai/
  And if the shell write is refused too, it says it can't reach the main checkout and stops
```

## Decisions

- **`.ai/` lives in the main checkout**: Why: one place to look per repo, and worktrees come and go. Not per worktree.
- **A bare repo falls back to the current checkout**: Why: there's no main checkout, and `.ai/` must never land in a git folder.
- **Outside a repo, `.ai/` goes in the folder itself**: Why: skills plan and research in folders that aren't repos too. Not refusing.
- **The ignore file is written only before a write**: Why: a lookup must leave the repo as it was.
