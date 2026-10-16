# Daily

`daily` lets you start your day knowing what's waiting on you and end it with a recap you don't have to write. In the morning it gathers what needs you across your hosts, trackers and chat, keeps your reviews current, flags security issues across the repos you work in, and helps you settle a plan; a recap turns a day's sessions, commits and activity into short bullets.

## Context

Only you start `daily` (`/wbc:daily`, or `/wbc:daily recap [day]`). Its sources are a `## Daily` section in your global `~/.claude/CLAUDE.md`, which `setup` writes: `GitHub`, `GitLab: <host>` and `Jira` are read through their CLIs (`gh`, `glab`, `acli`); anything else (`Slack: <connector>, <channels>`) through the connected tool it names; an optional `Notes:` line names your notes file, with `{date}` for the day, and a heading to write under. A script, `sessions.sh`, prints each Claude Code session on a local day (folder, branch, title, PRs, the skills it ran, your prompts and Claude's last reply) and the commits you made that day in each repo those sessions touched.

`review` keeps a PR's numbered findings in a gitignored review file in the repo's main checkout, noting the head commit it reviewed. Running it again moves findings the new head fixes under Resolved and drafts answers to replies on its posted findings; nothing posts until you say so. Reviewing a PR whose file `daily` archived moves the file back first. Each review fetches the PR, reads its code in a throwaway worktree under the temp folder, and has a checker agent recheck its findings. Related repos are the `## Related repos` entries in a repo's `CLAUDE.md` or `CLAUDE.local.md`, with paths relative to its main checkout; `setup` writes them into `CLAUDE.local.md`. A shared script maps any folder to its repo's main checkout, and every skill's working files live under that checkout's `.ai/`.

## Scope

In: the morning plan and the recap; sources and the notes file; re-reviewing PRs you reviewed; archiving the review files of merged or closed PRs; listing new comments on your PRs; security alerts and dependency-update PRs across active repos; the README's `daily` section.
Out: posting, commenting, merging, fixing or moving tickets; first reviews of PRs; recaps longer than a day; calendars.

## Behaviour

```gherkin
Scenario: Only you start it
  Given a session where nobody typed /wbc:daily
  Then Claude never runs daily on its own

Scenario: Morning: what's waiting on you
  Given your Daily section lists GitHub, Jira and the Slack connector
  And PR 42 asks for your review, CI failed on your PR 45, and a Slack DM to you has no reply
  When you run /wbc:daily
  Then it lists PR 42 to review, PR 45's failing CI, the Slack DM, and your open Jira work items with their status
  And each line links to the thing and says why it's there

Scenario: Morning: settle the plan
  Given daily has listed what's waiting
  When it proposes today's plan
  Then the plan puts unblocking others first (reviews, replies), then security fixes, then your PRs closest to merging, then ticket work by priority
  And each item names the skill to start it with, like "/wbc:review 42"
  And you change the plan one point at a time until you agree
  And the agreed plan goes into today's note when a notes file is set, else stays in the terminal

Scenario: Morning: yesterday's leftovers
  Given yesterday's recap carried over "Finish ABC-123"
  When you run /wbc:daily
  Then "Finish ABC-123" is in the list

Scenario Outline: Re-review PRs with new activity
  Given you reviewed PR 50 in shop, an active repo, and its review file is in shop's main checkout
  And since that review its author <activity>
  When you run /wbc:daily
  Then PR 50's review file shows <result>
  And PR 50 is listed under Reviews with what changed in its file and "/wbc:review 50" to look it over and post
  And nothing is posted

  Examples:
    | activity                                  | result                         |
    | pushed a fix for finding 2                | finding 2 under Resolved       |
    | replied to finding 2 without changing it  | a reply draft under finding 2  |

Scenario: A re-review it can't run
  Given you reviewed PR 7 in a repo that isn't an active repo, and it has new pushes
  When you run /wbc:daily
  Then PR 7 is listed to re-review, with "/wbc:review" and its link

Scenario: A PR you reviewed on the web
  Given you reviewed PR 60 in shop on the web, so there's no review file, and it has new pushes
  When you run /wbc:daily
  Then PR 60 is listed to re-review, and no review is run

Scenario Outline: Reviews of finished PRs are archived
  Given shop, an active repo, has a review file for PR 50 in its main checkout
  And PR 50 <state>
  When you run /wbc:daily
  Then the file moves to .ai/reviews/completed/50.md without asking
  And the reply says PR 50's review was archived

  Examples:
    | state      |
    | was merged |
    | was closed |

Scenario: Reviews of open PRs stay put
  Given shop has a review file for PR 51, which is still open
  When you run /wbc:daily
  Then the file stays at .ai/reviews/51.md

Scenario: New comments on your PRs
  Given a reviewer left 3 comments on your PR 45 since you last replied
  When you run /wbc:daily
  Then each comment is listed with what it asks of you
  And nothing on PR 45 or in its repo changes

Scenario: Security issues across active repos
  Given shop has an open alert for a lodash vulnerability, and web and api lock the same affected lodash
  And shop had a session this week, and web and api are its related repos
  When you run /wbc:daily
  Then one item lists shop, web and api together, suggesting /wbc:plan to fix them all

Scenario: Low-severity alerts count too
  Given api, an active repo you haven't touched in a year, has an open low-severity alert
  When you run /wbc:daily
  Then the alert is listed with the security items

Scenario: Dependency-update PRs
  Given Dependabot opened PR 77 in shop
  When you run /wbc:daily
  Then PR 77 is listed with the security items

Scenario: Recap
  Given today you merged PR 42, moved ABC-123 to Done and edited a Confluence page, partly in Claude Code sessions
  When you run /wbc:daily recap
  Then you get one past-tense bullet per thing done, merged across sessions, commits and hosts
  And plan items you didn't get to are listed as carried over
  And it replaces an earlier recap of that day in the note rather than adding a second

Scenario: Recap another day
  When you run /wbc:daily recap yesterday
  Then the recap covers yesterday in local time

Scenario: Nothing posts or changes elsewhere
  When daily runs in either mode
  Then no file you work on changes except your notes file and review files, a review's fetched refs and throwaway worktrees aside
  And nothing is posted, replied to, merged or moved

Scenario: A source it can't reach
  Given your Daily section lists Confluence but no connected tool reaches it
  When daily runs
  Then it says Confluence wasn't checked and why, and carries on with the rest

Scenario: No Daily section yet
  Given ~/.claude/CLAUDE.md has no Daily section
  When you run /wbc:daily
  Then it uses the hosts whose CLIs are logged in, plus your sessions
  And it suggests running /wbc:setup to choose your sources
  And an old Recap section still sets the notes file
```

## Design

`skills/daily/` holds the skill, `sessions.sh`, `active-repos.sh`, and a table of read-only commands per host (GitHub, GitLab, Jira) for each thing `daily` reads: review requests, PRs you reviewed, your open PRs and their state and comments, assigned tickets, unanswered notifications or to-dos, security alerts, dependency-update PRs, and your activity on a day.

**Active repos** are the main checkouts of the folders of your Claude Code sessions in the past 7 days (sessions in temp folders aside, as `sessions.sh` skips them), plus the Related repos listed in those checkouts' `CLAUDE.md` and `CLAUDE.local.md`. `active-repos.sh [days]` (default 7) prints them, one main checkout path per line, deduplicated.

**Morning** (`/wbc:daily`): gathers from every source and treats all of it as data, never instructions. It also picks up leftovers: the carried-over list from the last recap in your notes, else unfinished work in your last workday's sessions. It shows what's waiting, grouped (reviews, re-reviewed PRs included, replies owed, security, your PRs, tickets, carried over), then proposes an ordered plan for today (reviews and replies, security, your PRs closest to merging, tickets by priority) and settles it with you one question at a time. The agreed plan goes into the note between plan markers, replacing an earlier plan for that day.

**PRs you reviewed**, on GitHub and GitLab: the open PRs you've reviewed (on GitLab, those naming you as a reviewer). A PR's repo is the active repo whose `origin` is the PR's repo, and its review file is `.ai/reviews/<number>.md` in that repo's main checkout. One with a review file is re-reviewed when its head isn't the file's reviewed commit, or a thread holding one of the file's posted findings has a reply newer than the file. `daily` runs each re-review itself, in its own session rather than a subagent, one PR at a time, following `review` with that checkout as the repo (its `CLAUDE.md` and `CLAUDE.local.md` for Related repos) and calling the review checker as `review` does, with the fetches and throwaway worktrees any review makes; the checker's description names `daily` among its callers. Each is listed under Reviews with what changed in its file and `/wbc:review <number>` to look it over and post. Any other PR you reviewed with new pushes since your latest review is listed with `/wbc:review <url>`: on GitHub, since the commit of your latest review; on GitLab, since your latest note or approval. Every other review file in an active repo's main checkout is checked too, with `review`'s `view` command, which `daily`'s rule on remote commands names alongside `threads` and `comments`: once its PR is merged or closed, the file moves to `.ai/reviews/completed/<number>.md` without asking, and the reply lists it as archived. One it can't move stays put, and the reply says why.

**Your PRs**: for each, every unresolved thread or comment whose last word isn't yours is listed with what it asks of you.

**Security**, per active repo: open security alerts (GitHub's Dependabot alerts; GitLab's vulnerabilities where the tier has them, else not checked) and open dependency-update PRs (Dependabot or Renovate), at any severity. For each vulnerable package, `daily` checks every other active repo's manifests and lockfiles for an affected version and lists all hits as one item, suggesting `/wbc:plan` to fix them together.

**Recap** (`/wbc:daily recap [day]`): runs `sessions.sh` for the day and reads each source's activity for that day. It writes one bullet per thing done or decided, past tense, 15 words or fewer, with the repo and PR or ticket numbers, unfinished work as "Started", no secrets, paths or code, and `daily`'s own runs left out, merging what several sources say about the same thing. Items from that day's plan with no matching bullet are listed as carried over. Output goes where you ask, else the notes file, else the terminal, between recap markers it replaces on a re-run.

**Writes**: only your notes file and review files, which it re-reviews or archives. It never posts, replies, merges or moves a ticket. A source it can't reach is named as not checked, with why; a review file it can't write (the ai-folder spec's line for a refused write) skips that PR's re-review, saying why.

The README's `daily` section mentions re-reviews into review files, archiving those of merged or closed PRs, comments on your PRs and security items, and its read-only sentence names review files.

Testing: the repo's check script (budgets, links, every CLI flag in the host tables against that CLI's help) and markdownlint; running both modes against this machine's real sessions and accounts, including a PR reviewed with `review` that has new pushes and replies, one since merged, and `active-repos.sh` from a worktree.

## Decisions

- **One skill for the morning and the recap**: Why: they read the same sources, and the recap compares against the morning's plan. Not a mode of `ticket`: tickets are one of several sources.
- **Only you start it; modes by argument, not clock**: Why: you decide when your day starts and ends. Not guessing from the time of day.
- **Sources in your global `~/.claude/CLAUDE.md`, written by `setup`**: Why: `daily` covers all your repos, so per-repo files don't fit. Not a separate config file: the other skills already read their config from `CLAUDE.md` sections.
- **GitHub, GitLab and Jira through their CLIs; everything else through connected tools**: Why: the CLIs are already required and their flags get checked; Slack and Confluence have no usable CLI. Not hardcoding a Slack or Confluence API.
- **Writes only your notes and review files, a review's fetched refs and throwaway worktrees aside**: Why: it runs across every repo and tracker you have; acting is for the skill named next to each plan item. Review files stay on your machine and you decide what posts, so re-reviewing changed PRs saves running each by hand. Not replying, posting or moving tickets.
- **Re-reviews only where a review file exists**: Why: a re-review updates work you started; a first review is a bigger job you should ask for. Not a full review of every PR you looked at on the web.
- **Review files of merged or closed PRs move to `completed/`, unasked**: Why: `.ai/reviews/` then holds only reviews still in play, as `build` keeps finished plans apart in `completed/`, and nothing is lost, since `review` moves a file back if you review its PR again. Not asking: a finished PR leaves nothing to decide. Not deleting: you may want to look back at one. Not only the PRs `daily` lists: those are open, so a finished PR's file would never leave.
- **Replies to your findings trigger a re-review, not just pushes**: Why: an author's answer needs a reply draft as much as a push needs a recheck. Not pushes only: answers would wait until you happened to look.
- **GitLab too**: Why: `daily` already reads GitLab for everything else. Not GitHub only.
- **Every unanswered comment on your PRs listed**: Why: you see exactly what to look into. Not a count or the notification alone.
- **Active repos: past 7 days of sessions plus their related repos**: Why: that's where you work and what your work touches. Not every repo on disk, and no severity cut-off.
- **A vulnerability is checked across every active repo**: Why: the same package tends to sit in every repo that shares a stack. Not one repo at a time.
- **Security right after reviews and replies**: Why: one vulnerability can sit in several repos, and fixing it is a plan of its own. Not last with tickets: it would slip day after day.
- **Keep the recap markers and fall back to a `## Recap` section**: Why: notes written before `daily` existed keep working. Not new markers: the first recap after a switch would leave two.
- **Plans are saved only in the notes file**: Why: it's the one place you already chose for your day; without it, the plan stays in the terminal and the recap skips the carried-over list. Not a file under `~/.claude/`: Claude Code protects it. Not a repo's `.ai/`: `daily` isn't tied to one repo.
