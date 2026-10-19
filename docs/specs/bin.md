# Shared scripts

Answers more than one skill needs (which repos relate, which host a repo is on, its default branch, Markdown lint results) each come from one shared script in the plugin's `bin/` folder, so every skill gets the same answer and none reaches into another skill's folder. It's for the skills that run them and for whoever maintains the skills.

## Context

`scripts/check.py` checks the skills before each commit: links, word budgets, executable scripts, files nothing points at. In this repo, a markdownlint hook runs `lint-md.sh` on the Markdown Claude changes.

## Scope

In: the answers shared scripts give skills (related repos, a repo's host, its default branch, Markdown linting); which skills lint the Markdown they write; `check.py`'s checks of shared scripts and of the skills' Markdown templates; the AGENTS.md rules on skill scripts (shared ones live in `bin/`), on where a mechanical rule lives (a `bin/` script) and on linting the Markdown skills write (`lint-md.sh`).
Out: finding a folder's main checkout and its `.ai/` folder (the ai-folder spec) and cleaning up merged branches (the pr spec); scripts only one skill runs, which stay in that skill's folder; `setup` editing Related repos lines (the setup spec); a skill or script running a script from another skill's folder.

## Behaviour

```gherkin
Scenario Outline: The check catches a script run the wrong way
  Given <problem>
  When you run scripts/check.py
  Then it fails, naming <named>

  Examples:
    | problem                                                        | named                            |
    | a skill runs bin's related-repo.sh, a name that doesn't exist  | the skill and the missing script |
    | a skill runs a bin script that isn't executable                | the skill and the script         |
    | nothing runs a script in bin                                   | the script                       |
    | plan runs a script from review's folder                        | plan's file and the script       |
    | a skill writes .ai files but never runs lint-md.sh             | the skill                        |

Scenario: Related repos have one parser
  Given shop's CLAUDE.local.md lists "- acme/web (../web): calls /api/cart/*" under Related repos
  And its CLAUDE.md lists "- acme/api: serves the cart", with no path
  When plan, research, review or daily asks for shop's related repos, from shop or any worktree of it
  Then each gets acme/web with web's absolute path, resolved from shop's main checkout, and how it relates
  And acme/api with the path of the folder api beside shop's main checkout
  And a listed path that doesn't exist still comes back, for the skill to check

Scenario: Related repos outside a repo
  Given ~/notes isn't in a repo, and its CLAUDE.md lists Related repos
  When a skill asks for ~/notes' related repos
  Then it gets the entries from ~/notes' own files

Scenario: A repo's default branch comes fresh from origin
  Given shop's default branch on origin was renamed from master to main
  When a skill needs shop's default branch
  Then it gets main, read from origin just now

Scenario Outline: A repo whose host can't be told
  Given web's origin URL doesn't say GitHub or GitLab, and neither gh nor glab knows it
  When <skill> needs web's host
  Then <result>

  Examples:
    | skill   | result                                       |
    | pr      | it asks you which host web is on             |
    | daily   | it marks web as not checked and carries on   |

Scenario: A shared script's failure is passed on
  Given origin can't be reached
  When pr asks for shop's default branch
  Then it tells you why it couldn't get it, in the script's words

Scenario: Markdown a repo commits follows the repo's rules
  Given shop's .markdownlint.jsonc limits lines to 80 characters
  When build writes a spec with a 120-character line into shop's docs/specs/
  Then lint-md.sh reports that line, and build wraps it before committing
  And lint-md.sh lints only that spec, even if shop's config names files to lint across the repo

Scenario: Markdown git ignores follows the plugin's rules
  Given shop's .markdownlint.jsonc limits lines to 80 characters
  When plan writes a status.md with a 120-character line and no blank line under a heading into shop's .ai/plan/
  Then lint-md.sh adds the blank line and says nothing about the line's length

Scenario Outline: Skills lint the Markdown they write, but never your own files
  When <skill> writes <file>
  Then it <does>

  Examples:
    | skill                                                | file                                       | does                                   |
    | plan, research, review, release or prompt-writer     | a Markdown file in a repo                  | runs lint-md.sh, then fixes what's left |
    | setup                                                | a repo's CLAUDE.local.md                   | runs lint-md.sh, then fixes what's left |
    | build                                                | a spec in docs/specs/ or a plan folder file | runs lint-md.sh, then fixes what's left |
    | build                                                | any other doc in the repo                  | leaves it to the repo's own linter     |
    | daily                                                | your notes file                            | leaves it as written                   |
    | setup                                                | ~/.claude/CLAUDE.md                        | leaves it as written                   |

Scenario: A template that fails markdownlint fails the check
  Given a skill's template has a heading with no blank line under it
  When you run scripts/check.py
  Then it fails, naming the skill file, the line and the rule
  And a placeholder like <name> in a template never fails it

Scenario: No npx, no template check
  Given npx isn't installed
  When you run scripts/check.py
  Then it skips the templates and says so
```

## Decisions

- **Shared scripts in the plugin's `bin/`**: Why: no skill reaches into another skill's folder, and each answer still has one source. Not a copy per skill: copies drift. Not living in whichever skill used it first: every other caller then depends on that skill's folder.
- **Skills lint the Markdown they write**: Why: outside this repo, whose hook runs only here, nothing linted the specs, changelogs and plan files they wrote. Not a plugin hook: it would run on every edit in every repo and rewrite the user's own Markdown to rules they never picked.
- **A repo's rules for files it commits, the plugin's for the rest**: A committed file follows the repo's own markdownlint setup, if it has one (a config file in the file's folder or any folder above it up to the repo's top, or markdownlint in its `package.json`), the way the repo's own linter would. Files git ignores (`.ai/`, `CLAUDE.local.md`), files outside a repo, and repos with no setup follow the plugin's rules, which are also this repo's. Why: committed files face the repo's CI, while `.ai/` files and `CLAUDE.local.md` hold formats the skills read back. Not always the plugin's rules: committed specs would fail the repo's linter. Not always the repo's: markdownlint's default 80-character limit would hard-wrap plan files, and a required title heading would break `status.md`.
- **Your own files are never linted**: `daily`'s notes file and `~/.claude/CLAUDE.md`. Why: fixing them would rewrite lines you wrote.
