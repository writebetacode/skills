# writebetacode/skills

Claude Code skills for engineering productivity: small, single-purpose and lean, each doing one job well.

## Install

```sh
claude plugin marketplace add writebetacode/skills
claude plugin install wbc@writebetacode
```

Invoke a skill as `/wbc:<skill>`.

To update, run `claude plugin update wbc@writebetacode`. You only get a new copy when a release bumps the version, not on every commit.

## Requirements

You need [Git](https://git-scm.com/downloads) 2.38 or later, which `pr` and `build` use to tell when a branch's work has merged, squash merges included.

Each skill calls the CLI for the host it's working with, so install only the ones you use:

- [GitHub CLI](https://github.com/cli/cli#installation) (`gh`) for GitHub pull requests, issues and releases.
- [GitLab CLI](https://gitlab.com/gitlab-org/cli/-/blob/main/docs/installation_options.md) (`glab`) 1.115 or later for GitLab merge requests, issues and releases. `review`, and `build` when it answers review comments, need 1.122 or later.
- [Atlassian CLI](https://developer.atlassian.com/cloud/acli/guides/install-acli/) (`acli`) for Jira work items.
- [jq](https://jqlang.org/download/), which `review` uses to build GitHub comments, `daily` uses to read your sessions, and the GitLab skills use to look up your username.
- [Node.js](https://nodejs.org/en/download) (`npx`), which the skills use to run markdownlint on the Markdown files they write, like specs, changelogs, plans, findings and review files. A file your repo commits follows the repo's own markdownlint config if it has one.

`/wbc:setup` checks which of these you have, whether you're logged in, and whether your git is new enough.

## How they fit together

Most work moves through the skills in this order, each one handing off to the next:

1. `ticket` files or finds the ticket for the work.
2. `research` finds out what you need to know first, or why something's broken.
3. `plan` agrees on specs with you, then splits the work into tickets, one per pull request, and tasks, one per commit.
4. `build` builds the tasks test-first into pull requests and gets them through CI and review.
5. `review` reviews the pull requests other people write.
6. `release` ships a version.

A small fix with nothing left to decide can go straight to `build`, and anything `build` isn't sure about goes back to `plan`. `daily` wraps around the rest: in the morning it lists what's waiting on you, with the skill that starts each item, and at the end of the day it recaps what you did. `branch`, `commit` and `pr` are the git steps the others use, and you can run them on their own too. `same-page` is how every skill asks you something, one question at a time, and `voice` is how they all sound: everything they say to you or write for people goes through it, so it reads like one warm teammate wrote it.

## What waits for you

Nothing is committed, pushed, posted or merged until you say so:

- `build` stops after each task for you to look it over, and commits only when you say go. It asks before opening pull requests, and pushes or posts replies only after another go. It never merges.
- `build` starts on a plan only once you've approved its specs.
- `review` writes its findings to a file you can edit, and posts only when you say "post it".
- `research` changes nothing in your checkout. Its experiments run in throwaway worktrees.
- `setup` shows you every change first, and writes only once you confirm.
- `daily` only reads, apart from your notes file and the review files it refreshes. It never posts, merges or moves a ticket.
- `release` stops once the changelog is drafted, and ships only when you run `/wbc:release go`.

`ticket`, `commit` and `pr` act as soon as you ask them to, since asking is your go. If you'd like to see a ticket before it's filed, ask `ticket` for a draft. Claude never starts `setup`, `daily` or `release` on its own.

Plans, findings and review files stay on your machine in `.ai/` in the repo's main folder, ignored by git and shared by every worktree. From a worktree session, Claude writes them with shell commands, which may ask for your permission.

---

## Setup and daily skills

### wbc:setup

Run it when you install the plugin, and again when you start on another repo. It checks the CLIs and logins the skills need, works out which of your repos depend on each other, suggests debug tools for each, and sets up `daily`'s sources, writing nothing until you confirm.

### wbc:daily

Use it to start your day knowing what's waiting on you, and to end it with a recap you don't have to write. `/wbc:daily` gathers your reviews, replies owed, failing CI, security alerts and tickets into a plan for the day, and `/wbc:daily recap` turns the day's sessions and commits into short bullets.

To choose your sources and notes file, run `/wbc:setup`, or add this to your global `~/.claude/CLAUDE.md` (`{date}` becomes the day, like `2026-10-13`):

```md
## Daily
- Notes: ~/vault/Daily/{date}.md, under `## Claude`
- GitHub
- Jira
- Slack: Slack connector; DMs and mentions in #shop-dev
```

---

## Git skills

### wbc:branch

Use it to start new work from the latest default branch, with a name your team can read at a glance, like `feat/abc-123-login-lockout`. It can stack on another branch instead, and it never stashes or throws away your changes.

### wbc:commit

Use it so your history explains why things changed, without you writing the message. It commits only what you've staged, as a conventional commit tagged with the ticket from your branch name.

### wbc:pr

Use it to open, update or merge a pull request (or GitLab merge request) without hand-writing the title and description. It matches your repo's title style and template, and handles drafts and stacked PRs that have to merge in order.

### wbc:release

Use it to ship a version without putting the changelog together by hand. `/wbc:release` drafts the changelog and bumps your version files for you to edit, then `/wbc:release go` merges, tags and publishes it, picking up where it left off if anything stops it.

---

## Plan, build and review skills

### wbc:ticket

Use it to file, find or update a GitHub, GitLab or Jira ticket without leaving your session. It checks for an existing ticket before filing, and each kind has its own template that says what people see and why, never how to fix it.

### wbc:research

Use it when you need an answer before you decide, or need to know why something's broken. It answers with citations from the code, docs and web, tries things in a throwaway worktree when only trying will tell, and for a bug, proves the cause and writes findings you can hand to `plan` or `build`.

To tell it which logs, error trackers and databases it can read when it's chasing a bug, run `/wbc:setup`, or list them in the repo's `CLAUDE.md` or `CLAUDE.local.md`:

```md
## Debug tools
- Logs: `kubectl logs -n shop deploy/api --since=24h`
- Errors: Sentry MCP, project `shop-api`
- Database: read-only replica via `psql $REPLICA_URL`
```

### wbc:plan

Use it before anything bigger than a quick fix, so you and Claude agree on what you're building before any code exists. It talks the request through with you, writes a short spec for each area it touches, and once you approve them, splits the work into tickets (one per pull request) and tasks (one per commit).

### wbc:build

Use it to turn a plan, a bug's findings or a small change into tested, reviewed pull requests while you stay in charge of every commit. It builds one task at a time, tests first, has a fresh agent review each change and waits for your go before each commit or push, then gets the pull requests through CI and review.

### wbc:review

Use it to review a pull request, merge request or your uncommitted changes into a file you can edit before anything posts. It traces every name the change touches, in this repo and your related ones, holds the change to its ticket and your specs, and has a separate checker agent cut any finding that doesn't hold up.

To have it check repos that depend on this one, run `/wbc:setup`, or list them yourself in the repo's `CLAUDE.md` or `CLAUDE.local.md` (`plan` and `research` read the same list):

```md
## Related repos
- acme/web (../web): imports `@acme/cart`; calls `/api/cart/*`
```

---

## Writing skills

### wbc:voice

Use it when text is for people, so it reads like a warm teammate wrote it rather than an AI. It drafts and rewords replies, notes and docs, explains terse output in plain words, and every other skill runs what it writes for people through it.

### wbc:prompt-writer

Use it to write or slim down a skill, agent, prompt or subagent brief so it costs fewer tokens and behaves the same. It keeps only the lines that change what the agent does, never drops one of your rules when tightening, and suggests a skill instead of a new agent unless the job needs a fresh context of its own.

### wbc:same-page

Use it so you and Claude agree on what you mean before work starts. It plays your request back with examples that would catch a misreading and asks one question at a time until you confirm; the other skills use it whenever they need something from you.
