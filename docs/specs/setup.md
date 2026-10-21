# Setup

`setup` records what the other skills need from your machine: your CLIs, which repos depend on each other, where their logs and errors are, and `daily`'s sources. Rerun it to add repos or heal stale ones.

## Why

None of it is in the code, and paths differ per machine. Without it, `plan`, `research` and `review` can't follow a change into the repos it touches.

## What

It writes related repos and debug tools into each repo's `CLAUDE.local.md`, and `daily`'s sources into your global `~/.claude/CLAUDE.md`. It covers the repo you're in, plus paths you name or every git repo up to two levels under a folder you name. A rerun adds those already linked.

## Behaviour

- It asks one thing at a time (repos, tools, links, debug tools, `daily`'s sources), then shows every change and writes once you confirm.
- It checks git (2.38 or later), each host's CLI, Jira's if you use it, jq and npx. It gives you the install link or a login command to run with `!`, and never runs either.
- A repo with no debug tools listed gets proposed lines for its logs and errors, to confirm or fill in.
- A rerun keeps existing lines and never lists a repo twice.
- A linked repo that moved gets its new path in every `CLAUDE.local.md`. It reports one it can't find, or a stale path in a committed `CLAUDE.md`, for you to fix.
- A new `CLAUDE.local.md` in a repo with only `AGENTS.md` imports `AGENTS.md` first, so Claude keeps reading it.
- An existing `## Daily` section only gains missing source lines. Your answer about notes replaces its `Notes:` line.
- Refuse its write to `~/.claude/CLAUDE.md`, and you get the section to paste.
- A failed write stops it. Its reply lists the tool checklist, lines added per file, anything not written, and what's left for you.

## Sketch

A repo's `CLAUDE.local.md`. A link names the other repo by its origin's owner/repo, or its folder.

```md
## Related repos
- acme/web (../web): imports @acme/cart; calls /api/cart/*

## Debug tools
- Logs: `kubectl logs -n shop deploy/api --since=24h`
- Database: read-only replica via `psql $REPLICA_URL`
```

## Decisions

- **Links in each repo's `CLAUDE.local.md`, both ways**: Why: paths differ per machine, so they'd be wrong in the committed `CLAUDE.md`; each repo needs to know about the other.
- **Written to the main checkout, paths relative to it**: Why: one place per repo, which its worktrees load too; a worktree's copy would vanish with it.
- **Heal, never remove**: Why: a stale path misleads `plan`, `research` and `review`, and the sections may hold lines you wrote.
- **Out of git through your global excludes file**: Why: one change covers every repo. Not a repo's `.gitignore`, which you'd commit, or `.git/info/exclude`, which Claude Code protects, like git's default excludes file. With none set, you get the command.
- **Links only from evidence in the code, confirmed by you**: package dependencies, API calls, shared schemas or topics, compose files, submodules. Why: a wrong link sends `review` and `plan` into repos that don't matter.
- **Databases by variable or secret name, never a value**: Why: `CLAUDE.local.md` is plain text every session loads.
- **Only you start it**: Why: it writes into many repos and your git config.
- **One job: recording your tools, repos and sources**: Why: learning rules from sessions, drafting wbc issues and migrating `## Recap` sections were second jobs. Not a separate `learn` skill: one more description in every session.

## Out of scope

- Editing a repo's committed `CLAUDE.md`, `AGENTS.md` or `.gitignore`.
