# The .ai folder

Skills keep the files they make for you (plans, reviews, findings) in one gitignored `.ai/` folder in each repo's main checkout, never inside a linked worktree; a bare repo, which has no main checkout, is the one exception. You always know where to look, and removing a worktree loses nothing. That holds in a session Claude Code isolates in a worktree too: there, skills write `.ai/` with shell commands, since Claude Code refuses their file tools in the main checkout.

## Context

A repo can have several checkouts: the main one and any number of linked worktrees, including the ones Claude Code creates for worktree sessions under `<checkout>/.claude/worktrees/`, where `<checkout>` is the checkout the session started from, usually the main one. Each has its own top folder. `git worktree list` names the main checkout first, except in a bare repo, where the first entry is the bare git folder and there's no main checkout. A common bare layout keeps a folder like `~/code/shop` holding the bare git folder `.bare/`, a `.git` file pointing to it, and the worktrees (`~/code/shop/main`, …) side by side. Gitignored files in a worktree go when the worktree is removed.

When Claude Code isolates a session in a worktree (started with `--worktree`, entered with `EnterWorktree`, or resumed), it refuses the session's Edit, Write and NotebookEdit calls on any path in the main checkout, and shell commands that run there or point git at it. A plain shell command that writes there without git, like a redirect, isn't refused (one it can't parse well enough to verify, like a heredoc chained to another command, is): it goes through your permission settings, and Claude Code's sandbox, when it's on, lets shell commands write only inside the session's folder and the folders you allow.

Skills keep their own working files in the repos they work on only under `.ai/<area>/` (`plan` for plans and their findings, `reviews` for review files), keeping `.ai/` ignored by git with a `.gitignore` inside it that holds `*`. The other files they write are ones you commit (code, specs in `docs/specs/`) and `setup`'s `CLAUDE.local.md`. Apart from code in a Claude Code worktree, they never write under `.claude/` or `.git/`, which Claude Code protects. `review` and `plan`'s investigations also make throwaway worktrees of their own under the temp folder, holding only code.

## Scope

In: where `.ai/` lives; the scripts every skill uses to find the main checkout and `.ai/`; plans found from any worktree; writing `.ai/` from a session Claude Code isolates in a worktree; the AGENTS.md rule on where skills write; the README's mentions of `.ai/`; marking "Share `.ai/` across worktrees" Done in `docs/proposed-improvements.md`.
Out: the throwaway code worktrees `review` and `plan` make; moving `.ai/` folders that already exist in worktrees.

## Behaviour

```gherkin
Scenario Outline: Files land in the repo's main checkout
  Given a session in <folder>, <which>
  When it makes a plan
  Then the plan lands under <lands>, never inside a git folder or .claude

  Examples:
    | folder                                      | which                                                      | lands                      |
    | ~/code/shop-cart                            | a linked worktree of ~/code/shop                           | ~/code/shop/.ai/plan/      |
    | ~/code/shop/main                            | a worktree of the bare repo ~/code/shop                    | ~/code/shop/main/.ai/plan/ |
    | ~/code/shop/main/.claude/worktrees/fix-cart | a Claude Code worktree of the bare repo's ~/code/shop/main | ~/code/shop/main/.ai/plan/ |
    | ~/code/shop/lib                             | a submodule of ~/code/shop                                 | ~/code/shop/lib/.ai/plan/  |
    | ~/code/shop-cart/lib                        | that submodule in a linked worktree of ~/code/shop         | ~/code/shop/lib/.ai/plan/  |
    | ~/notes                                     | in no repo                                                 | ~/notes/.ai/plan/          |

Scenario: Reviews land in the main checkout too
  Given ~/code/shop-cart is a linked worktree of ~/code/shop
  When a session there reviews PR 50
  Then the review file is ~/code/shop/.ai/reviews/50.md

Scenario: Removing a worktree keeps its plans
  Given a plan made from a worktree of shop
  When that worktree is removed
  Then the plan is still under ~/code/shop/.ai/plan/

Scenario: Build finds a plan from a worktree
  Given a plan made in ~/code/shop
  When you run build in a session in one of shop's worktrees
  Then it finds the plan under ~/code/shop/.ai/plan/

Scenario: A removed Claude Code worktree still maps to its repo
  Given a session ran in ~/code/shop/.claude/worktrees/fix-cart, since removed
  When a skill asks which repo that folder belongs to
  Then the answer is ~/code/shop

Scenario: Looking up .ai changes nothing
  Given ~/code/web has no .ai folder
  When daily looks there for review files
  Then no .ai folder or ignore file is created

Scenario: Nothing is written where a bare repo has no checkout
  When a skill runs in a bare git folder, like ~/code/shop/.bare, or in the bare layout's ~/code/shop
  Then it refuses to write .ai there and says why

Scenario: A Claude Code worktree session writes .ai with shell commands
  Given a session Claude Code isolates in ~/code/shop/.claude/worktrees/fix-cart
  When it makes a plan, and Claude Code refuses to write the plan's files into ~/code/shop
  Then it writes them under ~/code/shop/.ai/plan/ with shell commands, never under the worktree's .ai/

Scenario: A sandboxed worktree session writes .ai with its file tools
  Given a session in ~/code/shop-cart, a linked worktree Claude Code doesn't isolate, whose sandbox won't let shell commands write into ~/code/shop
  And ~/code/shop has no .ai folder yet
  When it makes a plan
  Then it writes ~/code/shop/.ai/.gitignore holding "*" with its file tools, and the plan under ~/code/shop/.ai/plan/

Scenario: A sandbox that blocks the main checkout stops the skill
  Given a session Claude Code isolates in a worktree of shop, whose sandbox won't let shell commands write into ~/code/shop
  When plan or review needs to write a file there
  Then it says it can't reach the main checkout and stops, writing nothing in the worktree

Scenario: .ai stays out of git
  Given ~/code/shop has no .ai folder yet
  When a skill first writes there
  Then .ai/.gitignore holds "*", so git ignores everything in .ai
```

## Design

`skills/plan/main-checkout.sh [path]` (default: the current folder) prints the absolute path of that folder's main checkout. A folder under `<checkout>/.claude/worktrees/<name>/`, whether it still exists or not, maps as the same folder in `<checkout>` does, so a submodule in it maps to that submodule's checkout; when that folder doesn't exist in `<checkout>`, it maps as `<checkout>` does (its main checkout, or itself in a bare repo). Any other folder maps to the first `git worktree list` entry, or to its own top folder when that entry is bare; in a submodule that entry is the submodule's git folder under the parent's `.git/modules/`, whose `core.worktree` setting names the submodule's own checkout, which git reports as that folder's top. A submodule checked out inside a linked worktree maps as the same submodule in its superproject's main checkout does, when it's checked out there, since removing a worktree that holds a submodule takes `--force`, which deletes everything in it; a git folder that names no checkout (made with `--separate-git-dir`) maps to the folder's own top, as a bare repo does. A git folder, or a bare repo's own folder (like the bare layout's `~/code/shop`), exits 2; a folder in no repo exits 1.

`skills/plan/ai-dir.sh [--write] <area> [path]` uses it and prints the absolute `<main checkout>/.ai/<area>`; with `--write`, which a skill passes only when it's about to write, it first makes sure `.ai/.gitignore` there holds `*`, and exits 1 when it can't. When `main-checkout.sh` exits 1 it prints the absolute `<path>/.ai/<area>` (the current folder by default); when that exits 2, it exits 2 too, and the skill says why and writes nothing. `plan`, `build`, `review` and `daily` get every `.ai/` path from `ai-dir.sh`, every skill that needs a folder's repo asks `main-checkout.sh`, and their own copies of the ignore rule go.

In a session Claude Code isolates in a worktree, commands for that session's repo run in the worktree, never pointed at the main checkout; only the files above are written there. `plan`, `build`, `review`, `daily` and `setup` (for `CLAUDE.local.md`) each carry the same line for writing into the main checkout. When Edit or Write on one of those files is refused, they make its folder with one shell command, then write the file's whole text with another that expands nothing in it and can't end early inside it, each a plain command on its own, since Claude Code refuses a compound command it can't verify. When `ai-dir.sh --write` exits 1 (a sandbox stops its shell write from any worktree), they write `.ai/.gitignore` holding `*` themselves, either way, and run it again. When a shell write or that rerun fails, they say they can't reach the main checkout and stop; `daily`'s copy ends with its own spec's skip instead. They never write the worktree's copy instead.

The AGENTS.md rule on where skills write names the scripts and the line for a refused write. The README says plans and reviews stay in the repo's main folder, even when made from a worktree.

The "Share `.ai/` across worktrees" row in `docs/proposed-improvements.md` moves to Done.

Testing: the repo's check script (the scripts are linked and executable) and markdownlint; running both scripts from the main checkout, from a linked worktree, from a worktree of a bare repo, from a Claude Code worktree of a bare repo's worktree, from a submodule, from a submodule inside a linked worktree, inside a bare git folder, in the bare layout's own folder, for a removed Claude Code worktree, and outside a repo; a lookup without `--write` in a repo with no `.ai/`; and, in a session isolated in a Claude Code worktree of this repo, a Write into the main checkout's `.ai/` that's refused, then the shell write that follows.

## Decisions

- **`.ai/` lives in the main checkout**: Why: one place to look per repo, and worktrees come and go. Not per worktree.
- **Main checkout from `git worktree list`**: Why: it names the main checkout first and marks a bare repo, and a submodule's first entry, its git folder, leads to the submodule's checkout. Not the parent of the git common folder: it's wrong whenever the git folder lives elsewhere, as in a submodule or with `--separate-git-dir`, and it can't tell a bare repo.
- **A bare repo falls back to the current checkout**: Why: there's no main checkout, and `.ai/` must never land inside a git folder. Not the bare folder's parent: it may hold other repos.
- **Outside a repo, `.ai/` goes in the folder itself**: Why: `plan` answers questions and plans work in folders that aren't repos too, and there's no checkout to share. Not refusing: you'd lose the plan folder there.
- **Shared scripts**: Why: every skill needs the same answer and the same ignore rule. Not a copy of the rule in each skill.
- **Removed Claude Code worktrees map by path**: Why: their folder sits inside the checkout the session started from, so the path names the repo even after git forgets the worktree. Not dropping their sessions.
- **Shell writes when Claude Code refuses its file tools**: Why: a worktree session still keeps plans and reviews in the one place you look, and shell commands are the only way in; each may ask your permission. Not `.ai/` per worktree in those sessions: files would scatter and vanish with the worktree. Not stopping: you'd have to leave the worktree session to plan or review.
- **The refused-write line is a copy in each skill**: Why: it acts on a refusal the skill sees partway through its work, which no script can catch, and the write itself is two plain shell commands. Not a shared write script: each skill would still need the same line to say when to use it.
- **The ignore file is written only before a write**: Why: a lookup, like `daily` checking for review files, must leave the repo as it was. Not creating it on every call.
