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
- [Node.js](https://nodejs.org/en/download) (`npx`), which the skills use to run markdownlint on the Markdown files they write, like specs, changelogs, plans, findings and review files. A file your repo commits follows the repo's own markdownlint config if it has one.

`/wbc:setup` checks which of these you have and whether you're logged in.

---

## Setup and daily skills

### wbc:setup

Use it when you install the plugin, and again when you start on another repo, so `plan`, `research` and `review` know which of your repos depend on each other and where to find their logs and errors. It checks that the CLIs the skills need are installed and logged in, works out from the code which of your repos use each other, suggests debug tools for each, and writes them into each repo's `CLAUDE.local.md` (kept out of git), along with `daily`'s sources in your global `~/.claude/CLAUDE.md`, once you confirm. Run it again any time to add repos; it also fixes the path of a repo that moved. Claude never starts it on its own: type `/wbc:setup`.

### wbc:daily

Use it to start your day knowing what's waiting on you, and to end it with a recap you don't have to write. In the morning, `/wbc:daily` gathers review requests, failing CI, new comments on your pull requests, unanswered mentions and messages, security alerts and dependency updates in the repos you've worked in this week and the repos they rely on (checking each vulnerability across all of them), and your open tickets, then helps you settle on a plan for the day. Pull requests you reviewed with `review` that have new pushes or replies get re-reviewed into their review files, ready for you to look over and post. `/wbc:daily recap` (or `/wbc:daily recap yesterday`) turns that day's Claude Code sessions, commits and activity into short bullets and lists what carried over. It only reads, except for your notes file and those review files, and Claude never starts it on its own.

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

Use it to open, update or merge a pull request (or GitLab merge request) without hand-writing the title and description. It matches your repo's title style, fills your template, squashes on merge by default, and handles drafts and stacked PRs that have to merge in order. It won't open one from your default branch or merge while your branch has commits you haven't pushed, and it deletes a local branch only once all its work has merged. It handles one PR per branch and never comments on its size.

### wbc:release

Use it to ship a version without assembling the changelog by hand or forgetting a version file. It drafts the changelog and bumps the version wherever your project keeps it (`package.json` and its lockfile, `pyproject.toml`, `Cargo.toml`, a plugin manifest) for you to edit, then opens, merges, tags and publishes the release. Claude never starts it on its own: type `/wbc:release` to draft, edit the changelog, then `/wbc:release go` to ship. If it stops partway, say on a failing check, `/wbc:release go` picks up where it left off.

---

## Plan, build and review skills

### wbc:ticket

Use it to file, find or update a GitHub, GitLab or Jira ticket without leaving your session. Its tickets say what people see and why it matters, never how to fix it, so whoever picks one up is free to choose the fix. Before filing, it looks for the same problem among the project's open and closed tickets: an open one gets your case as a comment instead of a duplicate, and a closed or merely related one gets linked.

### wbc:research

Use it when you need an answer before you decide, or when something's broken and you need to know why. A plain question, like how something works here, which pattern to follow or which versions you're on, gets a cited report from the code, docs, web and connected tools, with nothing changed. For a bug, it first walks the failing code path one step at a time, rubber duck style, citing each line it read and flagging anything it only assumed, then proves the cause with an experiment in a throwaway worktree, has a separate checker agent poke holes in it, and writes the findings to `.ai/research/<name>/findings.md` in the repo's main folder (ignored by git, and shared by every worktree), ready to hand to `build` or `plan`. When `build` hits a CI test that passes on your machine, it hands it here: the test runs up to 50 times alone, then the whole suite a few times, to catch what makes it fail only sometimes, and the findings say whether the pull request caused it.

To tell it what it can use when it's chasing a bug, run `/wbc:setup`, or list your tools yourself in the repo's `CLAUDE.md` or `CLAUDE.local.md`:

```md
## Debug tools
- Logs: `kubectl logs -n shop deploy/api --since=24h`
- Errors: Sentry MCP, project `shop-api`
- Database: read-only replica via `psql $REPLICA_URL`
```

### wbc:plan

Use it before anything bigger than a quick fix, so you and Claude agree on what you're building before any code exists. It talks the request through with you, then writes or updates a spec for each area of your code the request touches: `docs/specs/` keeps one living spec per area (a skill, a service, a part of your app), named for it and kept true as each change lands. Each spec says what its area does and why, decisions included, and leaves how it's built to the tasks. A separate checker agent holds each one up against the spec rules, your repo's rules and the other specs before you see it. Once you approve them, it splits the work into commit-sized tasks that cover only what changed and say how to build it, with any dependency upgrade the change needs as its own task up front and the specs shipping in the first change. Ask it to split a branch that grew too big to review, and it plans pieces that each ship alone, reusing the branch's code and tests; the branch itself is left as it was. Bugs and questions go to `research` first; hand it the findings and it plans the fix. Each plan folder, `.ai/plan/<name>/`, stays on your machine in the repo's main folder, ignored by git and shared by every worktree, so `build` finds it wherever you run it. In a worktree session, Claude Code keeps its file tools out of the main folder, so skills write there with shell commands, which may ask for your permission.

### wbc:build

Use it to turn a plan, a bug write-up or a small change into tested, reviewed pull requests while you stay in charge of every commit; anything unclear, or too big for one pull request, goes to `plan` first, so it never has to ask what you meant. A pull request someone else wrote goes to `review` instead. It builds one task at a time, tests first, has a fresh agent review each change and a separate checker agent confirm each finding, and waits for your go before committing, then lands the pull requests: it rebases them after earlier ones merge, fixes failing CI from the job logs (a test that passes on your machine goes to `research` to find out why, and one the pull request didn't cause is reported with its findings) and drafts replies to review comments, and waits for your go again before it pushes or posts anything. Along the way, it fixes whatever its changes make untrue in your specs, README and other docs, in the same commit, and leaves your changelog's history alone.

### wbc:review

Use it to get a careful review of a pull request or merge request that you can edit before anyone sees it: findings land in `.ai/reviews/<number>.md` in the repo's main folder (ignored by git, and shared by every worktree), a separate checker agent, which sees none of the review's reasoning, rechecks each one, and nothing posts until you say so. It holds every pull request to your repo's specs: code that no longer matches a spec the pull request didn't update is blocking, asked as a question about which should change. Run it again to pick up new pushes and replies, or point it at your uncommitted changes for a local review, against a spec if you have one.

To have it check repos that depend on this one, run `/wbc:setup`, or list them yourself in the repo's `CLAUDE.md` or `CLAUDE.local.md` (`plan` and `research` read the same list):

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
