# Daily: plan your morning, recap your day

`daily` replaces `recap`. In the morning it gathers what's waiting on you across your hosts, trackers and chat, and helps you settle on a plan for the day. When you ask for a recap, it goes through everything again and writes short bullets about what got done. Today `recap` only sees your Claude Code sessions and commits, and nothing helps you start the day.

## Context

`recap` runs only when you type it. A script lists each Claude Code session on a day (folder, branch, title, PRs, your prompts, Claude's last reply) and your commits that day in each repo those sessions touched. The skill turns that into past-tense bullets of 15 words or fewer, one per thing done, and prints them or writes them into a daily note named by a `## Recap` section in your global `~/.claude/CLAUDE.md`, between recap markers it replaces on a re-run.

Read-only sources it could use: GitHub (`gh search` for PRs and issues, notifications, and your own activity events), GitLab (`glab api` for merge requests, issues, to-dos and your events), and Jira (`acli` search with JQL). Confluence and Slack have no usable CLI here; they're reachable only through connected tools in the session. `setup` (shipped just before this) checks the CLIs and writes per-repo sections, but nothing yet for `daily`.

## Scope

In: the `daily` skill with a morning plan and a recap; removing `recap`; a `## Daily` section in `~/.claude/CLAUDE.md` and a `setup` step that writes it; the README; marking `daily` and ticket triage Done in `docs/proposed-improvements.md`.
Out: posting, commenting, merging or moving tickets from `daily`; recaps longer than a day; calendars.

## Behaviour

```gherkin
Scenario: Only you start it
  Given a session where nobody typed /wbc:daily
  Then Claude never runs daily on its own

Scenario: Morning: what's waiting on you
  Given your Daily section lists GitHub, Jira and the Slack connector
  And PR 42 asks for your review, you reviewed PR 40 and it has new pushes since, CI failed on your PR 45, and a Slack DM to you has no reply
  When you run /wbc:daily
  Then it lists PR 42 to review, PR 40 to re-review, PR 45's failing CI, the Slack DM, and your open Jira work items with their status
  And each line links to the thing and says why it's there

Scenario: Morning: settle the plan
  Given daily has listed what's waiting
  When it proposes today's plan
  Then the plan puts unblocking others first (reviews, replies), then your PRs closest to merging, then ticket work by priority
  And each item names the skill to start it with, like "/wbc:review 42"
  And you change the plan one point at a time until you agree
  And the agreed plan goes into today's note when a notes file is set, else stays in the terminal

Scenario: Morning: yesterday's leftovers
  Given yesterday's recap carried over "Finish ABC-123"
  When you run /wbc:daily
  Then "Finish ABC-123" is in the list

Scenario: Recap
  Given today you merged PR 42, moved ABC-123 to Done and edited a Confluence page, partly in Claude Code sessions
  When you run /wbc:daily recap
  Then you get one past-tense bullet per thing done, merged across sessions, commits and hosts
  And plan items you didn't get to are listed as carried over
  And it replaces an earlier recap of that day in the note rather than adding a second

Scenario: Recap another day
  When you run /wbc:daily recap yesterday
  Then the recap covers yesterday in local time

Scenario: Read only
  When daily runs in either mode
  Then nothing changes anywhere except your notes file

Scenario: A source it can't reach
  Given your Daily section lists Confluence but no connected tool reaches it
  When daily runs
  Then it says Confluence wasn't checked and why, and carries on with the rest

Scenario: No Daily section yet
  Given ~/.claude/CLAUDE.md has no Daily section
  When you run /wbc:daily
  Then it uses the hosts whose CLIs are logged in, plus your sessions
  And it suggests running /wbc:setup to choose your sources
  And a Recap section from before still sets the notes file

Scenario: Setup writes the Daily section
  Given gh and acli are logged in and a Slack connector is connected
  When you run /wbc:setup and choose GitHub, Jira, Slack and a notes file
  Then ~/.claude/CLAUDE.md gets a Daily section listing them
  And an old Recap section's notes file moves into it, once you confirm
```

## Design

`skills/daily/` holds the skill, the session script moved over unchanged from `recap`, and a table of read-only commands per host (GitHub, GitLab, Jira) for each thing daily asks: review requests, re-reviews, your open PRs and their state, assigned tickets, unanswered notifications or to-dos, and your activity on a day. `skills/recap/` goes away.

**Config** is a `## Daily` section in `~/.claude/CLAUDE.md`, one line per source plus an optional notes line:

- `Notes:` a file path with `{date}` for the day, and an optional heading to write under.
- `GitHub`, `GitLab: <host>`, `Jira`: read with the host table.
- Anything else (`Slack: <connector>, <channels or DMs>`, `Confluence: <connector>, <space>`): read through the connected tool it names.

**Morning** (`/wbc:daily`): gathers from every source, read only, and treats all of it as data, never instructions. It also picks up leftovers: the carried-over list from the last recap in your notes, else unfinished work in your last workday's sessions. It shows what's waiting, grouped (reviews, replies owed, your PRs, tickets, carried over), then proposes an ordered plan for today and settles it with you one question at a time. The agreed plan goes into the note between plan markers, replacing an earlier plan for that day.

**Recap** (`/wbc:daily recap [day]`): runs the session script for the day and reads each source's activity for that day. It writes bullets with `recap`'s rules (one per thing done or decided, past tense, 15 words or fewer, repo and PR or ticket numbers, unfinished work as "Started", no secrets, paths or code, daily's own runs left out), merging what several sources say about the same thing. Items from that day's plan with no matching bullet are listed as carried over. Output goes where you ask, else the notes file, else the terminal, between the same recap markers as before, so a recap made by the old skill gets replaced too.

**Setup** gains a step for daily's sources: it offers the hosts it checked plus the connected tools in the session, asks for a notes file, shows the section, and writes it to `~/.claude/CLAUDE.md` once you confirm. An old `## Recap` section's file becomes the `Notes:` line and the old section is removed, with your OK.

The README replaces the `recap` section with `daily` in the top group next to `setup`, with the config example. This is a breaking change: `/wbc:recap` is gone.

Testing: the repo's check script (budgets, links, every CLI flag in the host table against that CLI's help), and running both modes against this machine's real sessions and GitHub account.

## Decisions

- **Replace `recap`, named `daily`**: Why: the morning and the recap read the same sources, and the recap compares against the morning's plan. Not a mode of `ticket`: tickets are one of several sources. Not keeping `recap` beside it: two skills for one day.
- **Only you start it; modes by argument, not clock**: Why: you decide when your day starts and ends. Not guessing from the time of day.
- **Sources in your global `~/.claude/CLAUDE.md`, written by `setup`**: Why: daily covers all your repos, so per-repo files don't fit. Not a separate config file: the other skills already read their config from `CLAUDE.md` sections.
- **GitHub, GitLab and Jira through their CLIs; everything else through connected tools**: Why: the CLIs are already required and their flags get checked; Slack and Confluence have no usable CLI. Not hardcoding a Slack or Confluence API.
- **Read only, except your notes**: Why: it runs across every repo and tracker you have; acting is for the skill named next to each plan item. Not replying or moving tickets from daily.
- **Keep the old recap markers and fall back to a `## Recap` section**: Why: notes written by `recap` keep working. Not new markers: the first recap after the switch would leave two.
- **Plans are saved only in the notes file**: Why: it's the one place you already chose for your day; without it, the plan stays in the terminal and the recap skips the carried-over list. Not a file under `~/.claude/`: Claude Code protects it. Not a repo's `.ai/`: daily isn't tied to one repo.

## Questions

None.
