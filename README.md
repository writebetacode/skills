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
- [jq](https://jqlang.org/download/), which `review` uses to build GitHub comments, `recap` uses to read your sessions, and the GitLab skills use to look up your username.

---

## Git skills

### wbc:branch

Use it so every piece of work starts from the latest default branch, with a name your team can read at a glance, like `feat/abc-123-login-lockout`. It can stack on another branch instead, and it never stashes or throws away your changes.

### wbc:commit

Use it so your history explains why things changed, without you writing the message. It commits only what you've staged, as a conventional commit tagged with the ticket from your branch name.

### wbc:pr

Use it to open, update or merge a pull request (or GitLab merge request) without hand-writing the title and description. It matches your repo's title style, fills your template, squashes on merge by default, and handles drafts and stacked PRs that have to merge in order. It won't merge while your branch has commits you haven't pushed, and it deletes a local branch only once all its work has merged.

### wbc:release

Use it to ship a version without assembling the changelog by hand or forgetting a version file. It drafts the changelog and bumps the version wherever your project keeps it (`package.json` and its lockfile, `pyproject.toml`, `Cargo.toml`, a plugin manifest) for you to edit, then opens, merges, tags and publishes the release. Claude never starts it on its own: type `/wbc:release` to draft, edit the changelog, then `/wbc:release go` to ship.

---

## Plan, build and review skills

### wbc:ticket

Use it to file, find or update a GitHub, GitLab or Jira ticket without leaving your session. Its tickets say what people see and why it matters, never how to fix it, so whoever picks one up is free to choose the fix.

### wbc:plan

Use it before anything bigger than a quick fix, so you and Claude agree on what you're building before any code exists, when something's broken and you need to know why, or when you need an answer before you decide, like how something works here, which pattern to follow or which versions you're on. It talks the request through with you, then writes a spec you approve and splits it into commit-sized tasks (the approved spec moves to `docs/specs/` and ships with the first change, complete enough to build from on its own, decisions and reasons included, and any older spec the change makes untrue gets updated too); for a bug, it first walks the failing code path one step at a time, rubber duck style, citing each line it read and flagging anything it only assumed, then proves the cause with an experiment in a throwaway worktree, has a separate checker agent poke holes in it, and writes the findings to `.ai/plan/<name>/`, which stays on your machine. A plain question gets a cited report from the code, docs, web and connected tools, with nothing changed and no plan folder.

To tell it what it can use when it's chasing a bug, list your tools in the repo's `CLAUDE.md` or `CLAUDE.local.md`:

```md
## Debug tools
- Logs: `kubectl logs -n shop deploy/api --since=24h`
- Errors: Sentry MCP, project `shop-api`
- Database: read-only replica via `psql $REPLICA_URL`
```

### wbc:build

Use it to turn a plan, a bug write-up or a small change into tested, reviewed pull requests while you stay in charge of every commit; anything too big for one pull request goes to `plan` first. It builds one task at a time, tests first, has a fresh agent review each change and a separate checker agent confirm each finding, and waits for your go before committing, then lands the pull requests: it rebases them after earlier ones merge, fixes failing CI from the job logs and drafts replies to review comments, and waits for your go again before it pushes or posts anything.

### wbc:review

Use it to get a careful review of a pull request or merge request that you can edit before anyone sees it: findings land in `.ai/reviews/<number>.md` (ignored by git), a separate checker agent, which sees none of the review's reasoning, rechecks each one, and nothing posts until you say so. Run it again to pick up new pushes and replies, or point it at your uncommitted changes for a local review, against a spec if you have one.

To have it check repos that depend on this one, list them in the repo's `CLAUDE.md` or `CLAUDE.local.md` (`plan` reads the same list):

```md
## Related repos
- acme/web (../web): imports `@acme/cart`; calls `/api/cart/*`
```

---

## Writing skills

### wbc:recap

Use it at the end of the day to see what you got done across all your Claude Code sessions, without digging back through them. It turns the day's sessions, and the commits you made that day in each repo they touched, into short, plain bullets and prints them, or adds them to a daily note; run it again and it replaces that day's recap rather than adding a second one.

To send recaps to your notes, add this to your global `~/.claude/CLAUDE.md` (`{date}` becomes the day, like `2026-10-13`):

```md
## Recap
- File: ~/vault/Daily/{date}.md, under `## Claude`
```

### wbc:voice

Use it when text is for people, so it reads like a teammate wrote it rather than an AI. It drafts and rewrites replies, notes and docs, explains terse output in plain words, and gives the other skills' commits, PRs, tickets, reviews, changelogs and specs the same voice.

### wbc:prompt-writer

Use it to write or slim down a skill, agent, prompt or subagent brief so it costs fewer tokens and behaves the same. It keeps only the lines that change what the agent does, and never drops one of your rules when tightening.

### wbc:same-page

Use it so you and Claude agree on what you mean before work starts, with one question at a time instead of a list. It plays your request back in plain words, with examples that would catch a misreading, and asks the one question that matters most until you confirm; Claude and the other skills use it whenever they need something from you.
