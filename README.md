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

Each skill calls the CLI for the host it's working with, so install only the ones you use:

- [GitHub CLI](https://github.com/cli/cli#installation) (`gh`) for GitHub pull requests, issues and releases.
- [GitLab CLI](https://gitlab.com/gitlab-org/cli/-/blob/main/docs/installation_options.md) (`glab`) 1.115 or later for GitLab merge requests, issues and releases. `review`, and `build` when it answers review comments, need 1.122 or later.
- [Atlassian CLI](https://developer.atlassian.com/cloud/acli/guides/install-acli/) (`acli`) for Jira work items.
- [jq](https://jqlang.org/download/), which `review` uses to build GitHub comments, `daily` uses to read your sessions, and the GitLab skills use to look up your username.

`/wbc:setup` checks which of these you have and whether you're logged in.

---

## Setup and daily skills

### wbc:setup

Use it when you install the plugin, and again when you start on another repo, so `plan` and `review` know which of your repos depend on each other and where to find their logs and errors. It checks that the CLIs the skills need are installed and logged in, works out from the code which of your repos use each other, suggests debug tools for each, and writes them into each repo's `CLAUDE.local.md` (kept out of git), along with `daily`'s sources in your global `~/.claude/CLAUDE.md`, once you confirm. Claude never starts it on its own: type `/wbc:setup`.

### wbc:daily

Use it to start your day knowing what's waiting on you, and to end it with a recap you don't have to write. In the morning, `/wbc:daily` gathers review requests, PRs to re-review, failing CI, unanswered mentions and messages, and your open tickets, then helps you settle on a plan for the day; `/wbc:daily recap` (or `/wbc:daily recap yesterday`) turns that day's Claude Code sessions, commits and activity into short bullets and lists what carried over. It only reads, except for your notes file, and Claude never starts it on its own.

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

Use it so every piece of work starts from the latest default branch, with a name your team can read at a glance, like `feat/abc-123-login-lockout`. It can stack on another branch instead, and it never stashes or throws away your changes.

### wbc:commit

Use it so your history explains why things changed, without you writing the message. It commits only what you've staged, as a conventional commit tagged with the ticket from your branch name.

### wbc:pr

Use it to open, update or merge a pull request (or GitLab merge request) without hand-writing the title and description. It matches your repo's title style, fills your template, squashes on merge by default, and handles drafts and stacked PRs that have to merge in order. It won't open one from your default branch or merge while your branch has commits you haven't pushed, and it deletes a local branch only once all its work has merged.

### wbc:release

Use it to ship a version without assembling the changelog by hand or forgetting a version file. It drafts the changelog and bumps the version wherever your project keeps it (`package.json` and its lockfile, `pyproject.toml`, `Cargo.toml`, a plugin manifest) for you to edit, then opens, merges, tags and publishes the release. Claude never starts it on its own: type `/wbc:release` to draft, edit the changelog, then `/wbc:release go` to ship. If it stops partway, say on a failing check, `/wbc:release go` picks up where it left off.

---

## Plan, build and review skills

### wbc:ticket

Use it to file, find or update a GitHub, GitLab or Jira ticket without leaving your session. Its tickets say what people see and why it matters, never how to fix it, so whoever picks one up is free to choose the fix.

### wbc:plan

Use it before anything bigger than a quick fix, so you and Claude agree on what you're building before any code exists, when something's broken and you need to know why, or when you need an answer before you decide, like how something works here, which pattern to follow or which versions you're on. It talks the request through with you, then writes or updates a spec for each area of your code the request touches: `docs/specs/` keeps one living spec per area (a skill, a service, a part of your app), named for it and kept true as each change lands, complete enough to build from on its own, decisions and reasons included. A separate checker agent holds each one up against the spec rules, your repo's rules and the other specs before you see it. Once you approve them, it proposes any dependency upgrades the feature needs (you withdraw the ones you don't want, the same way you would a review finding) and splits the work into commit-sized tasks that cover only what changed, with the specs shipping in the first change. For a bug, it first walks the failing code path one step at a time, rubber duck style, citing each line it read and flagging anything it only assumed, then proves the cause with an experiment in a throwaway worktree, has a separate checker agent poke holes in it, and writes the findings to its plan folder. A plain question gets a cited report from the code, docs, web and connected tools, with nothing changed and no plan folder. Each plan folder, `.ai/plan/<name>/`, stays on your machine in the repo's main folder, ignored by git and shared by every worktree, so `build` finds it wherever you run it. In a worktree session, Claude Code keeps its file tools out of the main folder, so skills write there with shell commands, which may ask for your permission.

To tell it what it can use when it's chasing a bug, run `/wbc:setup`, or list your tools yourself in the repo's `CLAUDE.md` or `CLAUDE.local.md`:

```md
## Debug tools
- Logs: `kubectl logs -n shop deploy/api --since=24h`
- Errors: Sentry MCP, project `shop-api`
- Database: read-only replica via `psql $REPLICA_URL`
```

### wbc:build

Use it to turn a plan, a bug write-up or a small change into tested, reviewed pull requests while you stay in charge of every commit; anything too big for one pull request goes to `plan` first. It builds one task at a time, tests first, has a fresh agent review each change and a separate checker agent confirm each finding, and waits for your go before committing, then lands the pull requests: it rebases them after earlier ones merge, fixes failing CI from the job logs and drafts replies to review comments, and waits for your go again before it pushes or posts anything.

### wbc:review

Use it to get a careful review of a pull request or merge request that you can edit before anyone sees it: findings land in `.ai/reviews/<number>.md` in the repo's main folder (ignored by git, and shared by every worktree), a separate checker agent, which sees none of the review's reasoning, rechecks each one, and nothing posts until you say so. Run it again to pick up new pushes and replies, or point it at your uncommitted changes for a local review, against a spec if you have one.

To have it check repos that depend on this one, run `/wbc:setup`, or list them yourself in the repo's `CLAUDE.md` or `CLAUDE.local.md` (`plan` reads the same list):

```md
## Related repos
- acme/web (../web): imports `@acme/cart`; calls `/api/cart/*`
```

---

## Writing skills

### wbc:voice

Use it when text is for people, so it reads like a teammate wrote it rather than an AI. It drafts and rewrites replies, notes and docs, explains terse output in plain words, and gives the other skills' commits, PRs, tickets, reviews, changelogs and specs the same voice.

### wbc:prompt-writer

Use it to write or slim down a skill, agent, prompt or subagent brief so it costs fewer tokens and behaves the same. It keeps only the lines that change what the agent does, and never drops one of your rules when tightening.

### wbc:same-page

Use it so you and Claude agree on what you mean before work starts, with one question at a time instead of a list. It plays your request back in plain words, with examples that would catch a misreading, and asks the one question that matters most until you confirm; Claude and the other skills use it whenever they need something from you.
