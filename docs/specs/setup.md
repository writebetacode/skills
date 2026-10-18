# Setup

`setup` walks you through everything the other skills read from your machine: the command-line tools, which of your repos depend on each other, how to reach each repo's logs and errors, and `daily`'s sources. Run it again any time; it heals what's gone stale, like a repo that moved, without touching lines you wrote.

## Context

`plan`, `research`, `review` and `daily` read `## Related repos`, and `research` reads `## Debug tools`, from the `CLAUDE.md` and `CLAUDE.local.md` of a repo's main checkout; `daily` reads `## Daily` from your global `~/.claude/CLAUDE.md`. The skills call `gh`, `glab`, `acli` and `jq`. Claude Code loads `CLAUDE.local.md` next to `CLAUDE.md` but doesn't ignore it in git for you, and adding one to a repo that has only `AGENTS.md` stops Claude reading `AGENTS.md` unless the new file imports it.

## Scope

In: the CLI checks; related repos; debug tools; `daily`'s sources; fixing Related repos paths that no longer resolve; the README's `setup` section.
Out: installing or logging in to CLIs for you; editing a repo's committed `CLAUDE.md`, `AGENTS.md` or `.gitignore`; learning rules from your sessions; drafting issues about wbc skills; migrating an old `## Recap` section; running a worktree session's own-repo commands in the worktree rather than pointed at the main checkout.

## Behaviour

```gherkin
Scenario: Only you start it
  Given a session where nobody typed /wbc:setup
  Then Claude never runs setup on its own

Scenario: CLI checks
  Given gh is installed but logged out, and acli isn't installed
  When you run setup
  Then it says gh needs "gh auth login", which you can run with "!"
  And it gives the install link for acli, and runs no login or install itself

Scenario: Link repos found in a folder
  Given ~/code/acme holds web, api and infra, and web calls api's cart endpoints
  When you point setup at ~/code/acme and confirm the links it shows
  Then web's CLAUDE.local.md lists acme/api with its path and how web uses it, and api's lists acme/web the same way
  And infra gets no entry, because nothing ties it to the others

Scenario: Nothing is written before you confirm
  Given setup has worked out its changes
  When you haven't confirmed them yet
  Then no file has changed

Scenario: Run it again to add a repo
  Given web and api are linked, and you added a line of your own to web's Related repos
  When you run setup again and add billing, which api calls
  Then api and billing gain entries for each other, and every existing line stays as it was

Scenario: A linked repo that moved is healed
  Given web's CLAUDE.local.md lists acme/api at ../api, and api now lives at ~/code/acme/services/api
  When you run setup again with api's new path
  Then only that line's path changes, in every CLAUDE.local.md that lists api
  And if web's committed CLAUDE.md lists api at its old path, setup tells you instead of editing it

Scenario: CLAUDE.local.md is kept out of git
  Given git doesn't ignore CLAUDE.local.md in web
  When setup is about to write it
  Then it asks once to add CLAUDE.local.md to your global git excludes file

Scenario: A repo that only has AGENTS.md
  Given api has AGENTS.md and no CLAUDE.md
  When setup creates api's CLAUDE.local.md
  Then the file imports AGENTS.md first

Scenario: Debug tools
  Given api has Kubernetes manifests and a Sentry config, and no Debug tools section
  When setup runs
  Then it proposes Debug tools lines for logs and errors for you to confirm or fill in

Scenario: Daily's sources
  Given gh and acli are logged in and a Slack connector is connected
  When you choose GitHub, Jira, Slack and a notes file
  Then ~/.claude/CLAUDE.md gets a Daily section listing them, with your notes file on its one Notes line
```

## Design

`setup` lives in `skills/setup/`, runs only when you type it, and asks one thing at a time:

1. Which repos: paths you name, or each git repo up to two levels under a folder, always with the one you're in. Each repo's lines go to its main checkout; a folder with no checkout is skipped, saying why. A re-run also re-reads the repos its Related repos sections list.
2. Tools: for each repo's host and for Jira if you use it, whether the CLI is installed and logged in, plus `jq` and `npx`, as a checklist with the command to fix each gap.
3. Links, from evidence in the code only: package dependencies, one calling another's API, shared schemas or topics, compose files, submodules. Each link is a line in both repos, in the form `related-repos.sh` reads (the bin spec): the other repo's name (its `origin`'s owner/repo, else its folder's name), its path relative to this repo's main checkout, and how they relate in a few words.
4. Debug tools, for repos without the section: lines from what the repo shows (cluster manifests, error-tracker config, compose files, a read-only database named by its variable or secret, never a value) and the session's connected tools.
5. `daily`'s sources, in the format the daily spec reads: logged-in hosts, and connected tools that read chat, docs or tickets with the channels to watch, plus a notes file with `{date}` and a heading. An existing `## Daily` only gains lines it lacks, and keeps one `Notes:` line, which your answer replaces.
6. It shows every change and writes nothing until you confirm. Before the first write, `CLAUDE.local.md` not ignored → it offers to append it to your global git excludes file; with none set, it gives you the `!` command for git's default location, which Claude Code protects. Then it writes each repo's main-checkout `CLAUDE.local.md`: a repo already listed by name, in that `CLAUDE.local.md` or the repo's `CLAUDE.md`, is skipped, a listed path that no longer resolves is replaced, in every repo's `CLAUDE.local.md` it reads, with the path of the same-named repo among this run's repos (one with no match stays and is listed as left for you), and no other line changes. A write that fails stops it there, and the reply says what it wrote and what it didn't.
7. Then `~/.claude/CLAUDE.md` gets the Daily section; a refused write → it shows the section for you to paste.
8. It replies with the checklist, the lines it added per file, and what's left for you.

In a session Claude Code isolates in a worktree, a refused write to `CLAUDE.local.md` follows the ai-folder spec's line, writing the file's whole text so a `$VAR` in a Debug tools line stays a name.

The README's `setup` section and the skill's description say nothing about learning from sessions or drafting issues.

Testing: the repo's check script and markdownlint; running it against a scratch folder of repos, including one that moved.

## Decisions

- **Links in each repo's `CLAUDE.local.md`, both ways**: Why: paths differ per machine, and both repos need to know about each other. Not the committed `CLAUDE.md`: your paths would land in every teammate's checkout.
- **Every write goes to the main checkout's `CLAUDE.local.md`**: Why: one place per repo, which Claude Code's worktrees inside it load too. Not each worktree's: lines would scatter and vanish with the worktree.
- **Related repos paths are relative to the main checkout**: Why: the file lives there, and a worktree sits deeper inside it. Not relative to wherever a skill runs.
- **Self-healing, never removing**: Why: a stale path sends `plan`, `research` and `review` to the wrong place, while the sections may hold lines you wrote. Not regenerating a section, and not leaving a moved repo for you to fix by hand.
- **Ignored through your global git excludes file**: Why: one change covers every repo. Not each repo's `.gitignore`, which you'd commit, or `.git/info/exclude`, which Claude Code protects. With no excludes file set, you get the command, since git's default location is under a folder Claude Code protects.
- **setup reads and edits Related repos lines itself**: Why: it rewrites lines in place, which needs the raw text; the other skills only read, through `related-repos.sh`.
- **Databases by variable or secret name, never a value**: Why: `CLAUDE.local.md` is plain text every session loads.
- **Links only from evidence in the code, confirmed by you**: Why: a wrong link sends `review` and `plan` into repos that don't matter. Not guessing from names.
- **`~/.claude/CLAUDE.md` is written once, after you confirm**: Why: that's where `daily` reads its sources, and Claude Code loads only that file in every session; it asks before each write there, so a refusal means you paste the section yourself.
- **Only you start it**: Why: it writes into many repos and your git config.
- **No learning from sessions, wbc issue drafts or `## Recap` migration**: Why: each was a second job for a skill whose one job is recording your tools, repos and sources, and no one has an old `## Recap` section left. Not keeping them in setup, and not a separate `learn` skill: one more description in every session.
