# Setup

`setup` walks you through everything the other skills read from your machine: the command-line tools, which of your repos depend on each other, how to reach each repo's logs and errors, and `daily`'s sources. Run it again any time; it heals what's gone stale, like a repo that moved, without touching lines you wrote.

## Context

`plan`, `research`, `review` and `daily` read `## Related repos`, and `research` reads `## Debug tools`, from the `CLAUDE.md` and `CLAUDE.local.md` of a repo's main checkout; `daily` reads `## Daily` from your global `~/.claude/CLAUDE.md`. The skills call `git`, which some of them need at 2.38 or later, `gh`, `glab`, `acli` and `jq`. Claude Code loads `CLAUDE.local.md` next to `CLAUDE.md` but doesn't ignore it in git for you, and adding one to a repo that has only `AGENTS.md` stops Claude reading `AGENTS.md` unless the new file imports it.

## Scope

In: the CLI checks; related repos; debug tools; `daily`'s sources; fixing Related repos paths that no longer resolve; the README's `setup` section.
Out: installing or logging in to CLIs for you; editing a repo's committed `CLAUDE.md`, `AGENTS.md` or `.gitignore`; learning rules from your sessions; drafting issues about wbc skills; migrating an old `## Recap` section; running a worktree session's own-repo commands in the worktree rather than pointed at the main checkout.

## Behaviour

```gherkin
Scenario: Only you start it
  Given a session where nobody typed /wbc:setup
  Then Claude never runs setup on its own

Scenario: It asks one thing at a time
  When you run setup
  Then it asks which repos, then checks tools, links repos, proposes debug tools and sets daily's sources, one question at a time

Scenario Outline: Which repos
  Given you're in ~/code/acme/web
  When you run setup and <answer>
  Then its repos are <repos>, and each repo's lines go to its main checkout

  Examples:
    | answer                                   | repos                                                             |
    | name ~/code/acme/api                     | web and api                                                       |
    | point it at ~/code/acme                  | web and each git repo up to two levels under ~/code/acme          |
    | run it again                             | web plus each repo web's Related repos sections list              |

Scenario: A folder with no checkout is skipped
  Given ~/code/acme/shop is a bare repo with no main checkout
  When setup looks at the repos under ~/code/acme
  Then it skips shop and says why

Scenario: CLI checks
  Given gh is installed but logged out, acli isn't installed, and git is 2.34
  When you run setup
  Then it shows a checklist of git, the CLI for each repo's host, Jira's if you use it, jq and npx, each installed and logged in or not
  And it says gh needs "gh auth login", which you can run with "!"
  And it says git needs 2.38 or later, with git's install link
  And it gives the install link for acli, and runs no login or install itself

Scenario: Link repos found in a folder
  Given ~/code/acme holds web, api and infra, and web calls api's cart endpoints
  When you point setup at ~/code/acme and confirm the links it shows
  Then web's CLAUDE.local.md lists acme/api with its path and how web uses it, and api's lists acme/web the same way
  And infra gets no entry, because nothing ties it to the others

Scenario: What makes a link
  When setup looks for links between repos
  Then it finds them only from evidence in the code: package dependencies, one calling another's API, shared schemas or topics, compose files, submodules
  And each link's line names the other repo by its origin's owner/repo, else its folder's name, with its path relative to this repo's main checkout and how they relate in a few words

Scenario: Nothing is written before you confirm
  Given setup has worked out its changes
  When you haven't confirmed them yet
  Then it has shown you every change, and no file has changed

Scenario: Run it again to add a repo
  Given web and api are linked, and you added a line of your own to web's Related repos
  When you run setup again and add billing, which api calls
  Then api and billing gain entries for each other, and every existing line stays as it was
  And a repo already listed by name, in a CLAUDE.local.md or the repo's CLAUDE.md, gets no second entry

Scenario: A linked repo that moved is healed
  Given web's CLAUDE.local.md lists acme/api at ../api, and api now lives at ~/code/acme/services/api
  When you run setup again with api's new path
  Then only that line's path changes, in every CLAUDE.local.md that lists api
  And if web's committed CLAUDE.md lists api at its old path, setup tells you instead of editing it

Scenario: A moved repo it can't find
  Given web's CLAUDE.local.md lists acme/legacy at a path that no longer resolves
  And no repo in this run is named legacy
  When setup runs
  Then that line stays, and the reply lists it as left for you

Scenario Outline: CLAUDE.local.md is kept out of git
  Given git doesn't ignore CLAUDE.local.md in web, and <excludes>
  When setup is about to write it
  Then <offer>

  Examples:
    | excludes                               | offer                                                                         |
    | you have a global git excludes file    | it asks once to add CLAUDE.local.md to that file                              |
    | no global excludes file is set         | it gives you the "!" command that adds it at git's default location           |

Scenario: A repo that only has AGENTS.md
  Given api has AGENTS.md and no CLAUDE.md
  When setup creates api's CLAUDE.local.md
  Then the file imports AGENTS.md first

Scenario: Debug tools
  Given api has Kubernetes manifests and a Sentry config, and no Debug tools section
  When setup runs
  Then it proposes Debug tools lines for logs and errors, from what api shows and the session's connected tools, for you to confirm or fill in
  And a read-only database is named by its variable or secret, never its value

Scenario: Daily's sources
  Given gh and acli are logged in and a Slack connector is connected
  When you choose GitHub, Jira, Slack with the channels to watch, and a notes file
  Then ~/.claude/CLAUDE.md gets a Daily section listing them, with your notes file, its {date} and heading on its one Notes line
  And an existing Daily section only gains lines it lacks, and your answer replaces its Notes line

Scenario: A refused write to your global CLAUDE.md
  Given you refuse setup's write to ~/.claude/CLAUDE.md
  When setup carries on
  Then it shows you the Daily section to paste yourself

Scenario: A write that fails
  Given setup has written web's CLAUDE.local.md
  When its write to api's CLAUDE.local.md fails
  Then it stops there, and the reply says what it wrote and what it didn't

Scenario: A worktree session
  Given a session Claude Code isolates in a worktree of api
  When Claude Code refuses setup's write to api's main-checkout CLAUDE.local.md
  Then setup writes it with shell commands, as the ai-folder spec says
  And a $VAR in a Debug tools line stays written as its name

Scenario: The reply
  When setup is done
  Then it replies with the CLI checklist, the lines it added to each file, and what's left for you
```

## Decisions

- **Links in each repo's `CLAUDE.local.md`, both ways**: Why: paths differ per machine, and both repos need to know about each other. Not the committed `CLAUDE.md`: your paths would land in every teammate's checkout.
- **Every write goes to the main checkout's `CLAUDE.local.md`**: Why: one place per repo, which Claude Code's worktrees inside it load too. Not each worktree's: lines would scatter and vanish with the worktree.
- **Related repos paths are relative to the main checkout**: Why: the file lives there, and a worktree sits deeper inside it. Not relative to wherever a skill runs.
- **Self-healing, never removing**: Why: a stale path sends `plan`, `research` and `review` to the wrong place, while the sections may hold lines you wrote. Not regenerating a section, and not leaving a moved repo for you to fix by hand.
- **Ignored through your global git excludes file**: Why: one change covers every repo. Not each repo's `.gitignore`, which you'd commit, or `.git/info/exclude`, which Claude Code protects. With no excludes file set, you get the command, since git's default location is under a folder Claude Code protects.
- **Databases by variable or secret name, never a value**: Why: `CLAUDE.local.md` is plain text every session loads.
- **Links only from evidence in the code, confirmed by you**: Why: a wrong link sends `review` and `plan` into repos that don't matter. Not guessing from names.
- **`~/.claude/CLAUDE.md` is written once, after you confirm**: Why: that's where `daily` reads its sources, and Claude Code loads only that file in every session; it asks before each write there, so a refusal means you paste the section yourself.
- **Only you start it**: Why: it writes into many repos and your git config.
- **No learning from sessions, wbc issue drafts or `## Recap` migration**: Why: each was a second job for a skill whose one job is recording your tools, repos and sources, and no one has an old `## Recap` section left. Not keeping them in setup, and not a separate `learn` skill: one more description in every session.
