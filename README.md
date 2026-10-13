# writebetacode/skills

Claude Code skills for engineering productivity: small, single-purpose and lean, each pinned by quick evals so it does its one job the same way every time.

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
- [GitLab CLI](https://gitlab.com/gitlab-org/cli/-/blob/main/docs/installation_options.md) (`glab`) 1.115 or later for GitLab merge requests, issues and releases. `review` needs 1.122 or later.
- [Atlassian CLI](https://developer.atlassian.com/cloud/acli/guides/install-acli/) (`acli`) for Jira work items.
- [jq](https://jqlang.org/download/), which `review` uses to build GitHub comments and the GitLab skills use to look up your username.

---

## Git skills

### wbc:branch

Use it so every piece of work starts from the latest default branch, with a name your team can read at a glance, like `feat/abc-123-login-lockout`. It can stack on another branch instead, and it never stashes or throws away your changes.

### wbc:commit

Use it so your history explains why things changed, without you writing the message. It commits only what you've staged, as a conventional commit tagged with the ticket from your branch name.

### wbc:pr

Use it to open, update or merge a pull request (or GitLab merge request) without hand-writing the title and description. It matches your repo's title style, fills your template, squashes on merge by default, and handles drafts and stacked PRs that have to merge in order. It won't merge while your branch has commits you haven't pushed, and it deletes a local branch only once all its work has merged.

### wbc:release

Use it to ship a version without assembling the changelog by hand or forgetting a version file. It drafts the changelog and bumps the version wherever your project keeps it (`package.json` and its lockfile, `pyproject.toml`, `Cargo.toml`, a plugin manifest) for you to edit, then opens, merges, tags and publishes the release.

---

## Plan, build and review skills

### wbc:ticket

Use it to file or update a GitHub, GitLab or Jira ticket without leaving your session. Its tickets say what people see and why it matters, never how to fix it, so whoever picks one up is free to choose the fix.

### wbc:sdlc-plan

Use it before anything bigger than a quick fix, so you and Claude agree on what you're building before any code exists. It talks the request through with you (or starts from a `debug` write-up), writes a spec you approve, and splits it into commit-sized tasks grouped into merge requests under `.ai/sdlc/<name>/`.

### wbc:sdlc-build

Use it to turn an approved plan into tested, reviewed code while you stay in charge of every commit. It builds one task at a time, tests first, has a fresh agent review each change and a separate checker agent confirm each finding, waits for your go before committing, then opens the merge requests in order. When you close a plan, it deletes the plan's local branches whose work has fully merged and keeps any that still hold something.

### wbc:review

Use it to get a careful review of a pull request or merge request that you can edit before anyone sees it: findings land in `.ai/reviews/<number>.md` (ignored by git), a separate checker agent, which sees none of the review's reasoning, rechecks each one, and nothing posts until you say so. Run it again to pick up new pushes and replies, or point it at your uncommitted changes for a local review, against a spec if you have one.

To have it check repos that depend on this one, list them in the repo's `CLAUDE.md` or `CLAUDE.local.md` (`sdlc-plan` reads the same list):

```md
## Related repos
- acme/web (../web): imports `@acme/cart`; calls `/api/cart/*`
```

---

## Research and writing skills

### wbc:research

Use it when you need an answer before you decide or act, like how something works here, which pattern to follow or which versions you're on. It digs through the code, docs, web and connected tools and hands back a cited report without changing anything.

### wbc:debug

Use it when something's broken and you want to know where to start looking. Once you agree on the problem, it digs through the code, git history, logs and any tools you've listed, asks you only what it can't find out itself, has a separate checker agent poke holes in its answer, then writes the likely cause and one or two fixes to `.ai/debug/<name>/findings.md` and cleans up any experiments it ran; point it at an earlier write-up to keep digging.

To tell it what it can use, list your tools in the repo's `CLAUDE.md` or `CLAUDE.local.md`:

```md
## Debug tools
- Logs: `kubectl logs -n shop deploy/api --since=24h`
- Errors: Sentry MCP, project `shop-api`
- Database: read-only replica via `psql $REPLICA_URL`
```

### wbc:voice

Use it when text is for people, so it reads like a teammate wrote it rather than an AI. It drafts and rewrites replies, notes and docs, explains terse output in plain words, and gives the other skills' commits, PRs, tickets, reviews, changelogs and specs the same voice.

### wbc:prompt-writer

Use it to write or slim down a skill, agent, prompt or subagent brief so it costs fewer tokens and behaves the same. It keeps only the lines that change what the agent does, and never drops one of your rules when tightening.

### wbc:same-page

Use it so you and Claude agree on what you mean before work starts, with one question at a time instead of a list. It plays your request back in plain words, with examples that would catch a misreading, and asks the one question that matters most until you confirm; Claude and the other skills use it whenever they need something from you.
