# Daily

`daily` lets you start your day knowing what's waiting on you and end it with a recap you don't have to write. In the morning it gathers what needs you across your hosts, trackers and chat, keeps your reviews current, flags security issues across the repos you work in, and helps you settle a plan; a recap turns a day's sessions, commits and activity into short bullets.

## Context

Only you start `daily` (`/wbc:daily`, or `/wbc:daily recap [day]`). Its sources are a `## Daily` section in your global `~/.claude/CLAUDE.md`, which `setup` writes: `GitHub`, `GitLab: <host>` and `Jira` are read through their CLIs; anything else (`Slack: <connector>, <channels>`) through the connected tool it names; an optional `Notes:` line names your notes file, with `{date}` for the day, and a heading to write under. `sessions.sh` prints each Claude Code session on a local day (folder, branch, title, PRs, the skills it ran, your prompts and Claude's last reply) and the commits you made that day in the repos those sessions touched.

`review` keeps a PR's findings in a gitignored review file in the repo's main checkout. Running it again re-reviews new pushes and replies, or says the file is current; nothing posts until you say so.

## Scope

In: the morning plan and the recap; sources and the notes file; re-reviewing PRs you reviewed, through `review`; new comments on your PRs; security alerts and dependency-update PRs across active repos; the README's `daily` section.
Out: posting, commenting, merging, fixing or moving tickets; first reviews; recaps longer than a day; calendars; archiving review files; reading an old `## Recap` section.

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
  Then reviews and replies come first, then security fixes, then your PRs closest to merging, then tickets by priority
  And each item names the skill to start it with, like "/wbc:review 42"
  And the plan you agree goes into today's note when a notes file is set

Scenario: Morning: yesterday's leftovers
  Given yesterday's recap carried over "Finish ABC-123"
  When you run /wbc:daily
  Then "Finish ABC-123" is in the list

Scenario: Re-review a PR you reviewed with review
  Given you reviewed PR 50 in shop, an active repo, with review, and its author has since pushed a fix
  When you run /wbc:daily
  Then it runs review on PR 50, which updates its review file
  And PR 50 is listed under Reviews with what changed and "/wbc:review 50" to look it over and post
  And nothing is posted

Scenario Outline: A PR you reviewed without review
  Given you reviewed PR 60 on the web, so there's no review file, and it <activity>
  When you run /wbc:daily
  Then PR 60 is <result>, and no review runs

  Examples:
    | activity                         | result                                    |
    | has pushes since your review     | listed with "/wbc:review" and its link    |
    | has nothing new since your review | not listed                                |

Scenario: New comments on your PRs
  Given a reviewer left 3 comments on your PR 45 since you last replied
  When you run /wbc:daily
  Then each comment is listed with what it asks of you

Scenario: Security issues across active repos
  Given shop has an open alert for a lodash vulnerability, and web and api lock the same affected lodash
  And shop had a session this week, and web and api are its related repos
  When you run /wbc:daily
  Then one item lists shop, web and api together, suggesting /wbc:build to fix them

Scenario: Recap
  Given today you merged PR 42, moved ABC-123 to Done and edited a Confluence page, partly in Claude Code sessions
  When you run /wbc:daily recap
  Then you get one past-tense bullet per thing done, merged across sessions, commits and hosts
  And plan items you didn't get to are listed as carried over
  And it replaces an earlier recap of that day in the note rather than adding a second

Scenario: Nothing posts or changes elsewhere
  When daily runs in either mode
  Then nothing changes except your notes file and the review files review updates, a review's fetched refs and throwaway worktrees aside
  And nothing is posted, replied to, merged or moved

Scenario: A source it can't reach
  Given your Daily section lists Confluence but no connected tool reaches it
  When daily runs
  Then it says Confluence wasn't checked and why, and carries on with the rest

Scenario: No Daily section yet
  Given ~/.claude/CLAUDE.md has no Daily section
  When you run /wbc:daily
  Then it uses the hosts whose CLIs are logged in, plus your sessions, and suggests /wbc:setup
```

## Design

`skills/daily/` holds the skill, `sessions.sh`, `active-repos.sh`, a table of read-only commands per host, and the steps for reviews and security.

**Active repos** are the main checkouts of your Claude Code sessions' folders in the past 7 days (temp folders aside), plus the `## Related repos` entries of each checkout's `CLAUDE.md` and `CLAUDE.local.md`, read through the shared `related-repos.sh`. `active-repos.sh [days]` prints them, one per line.

**Morning** gathers from every source, plus leftovers (the carried-over list from your last recap, else unfinished work in your last day's sessions), shows what's waiting grouped by kind, proposes the ordered plan and settles it with you one question at a time. The agreed plan goes into the note between `<!-- plan:start -->` and `<!-- plan:end -->` markers, replacing an earlier plan for that day.

**PRs you reviewed.** For each open PR you reviewed (on GitLab, those naming you as reviewer), its repo is the active repo whose `origin` is the PR's repo, and its review file is `<number>.md` under that checkout's `.ai/reviews/`. When that file exists, `daily` runs `review` on the PR in `daily`'s own session, not a subagent, one PR at a time, with that checkout as the repo; `review` re-reviews it or says it's current. A `review` run that stops ends only that PR's re-review: `daily` says why and moves on. Re-reviewed ones are listed with what changed in their file. Any other PR you reviewed is listed with `/wbc:review <url>` only when it has pushes since your latest review (on GitLab, since your latest note or approval).

**Your PRs**: each unresolved thread or comment whose last word isn't yours is listed with what it asks.

**Security**, per active repo, at any severity: open alerts (Dependabot; GitLab's vulnerabilities where the tier shows them, else not checked) and open Dependabot or Renovate PRs. Each vulnerable package is checked across every other active repo's manifests and lockfiles; all hits make one item, suggesting `/wbc:build` to fix them.

**Recap** runs `sessions.sh` for the day and reads each source's activity, then writes one past-tense bullet per thing done or decided, 15 words or fewer, with no secrets, paths or code and `daily`'s own runs left out. Plan items with no matching bullet are carried over. Output goes where you ask, else the notes file between `<!-- recap:start -->` and `<!-- recap:end -->` markers, replacing an earlier recap of that day, else the terminal.

The README's `daily` section mentions re-reviews through `review`, comments on your PRs and security items, with no sentence about archiving review files.

Testing: the repo's check script (including every CLI flag in the host tables) and markdownlint; both modes against this machine's real sessions and accounts, including a PR reviewed with `review` that has new pushes.

## Decisions

- **One skill for the morning and the recap**: Why: they read the same sources, and the recap compares against the morning's plan.
- **Only you start it; modes by argument, not clock**: Why: you decide when your day starts and ends.
- **Sources in your global `~/.claude/CLAUDE.md`**: Why: `daily` covers all your repos, so per-repo files don't fit, and the other skills already read config from `CLAUDE.md` sections.
- **Writes only your notes file, plus review files through `review`, a review's fetched refs and throwaway worktrees aside**: Why: it runs across every repo and tracker you have; acting is for the skill named next to each plan item.
- **Re-reviews go through `review`, which decides if anything changed**: Why: one place decides whether a review is current. Not `daily` checking heads and threads itself: a second copy of `review`'s rule. It costs one `review` load per PR with a file.
- **Re-reviews run in `daily`'s own session, one at a time**: Why: `review` starts the review checker, which a subagent can't do. Not a subagent per PR.
- **Re-reviews only where a review file exists**: Why: a re-review updates work you started; a first review is a bigger job you should ask for.
- **Active repos: the past 7 days of sessions plus their related repos**: Why: that's where you work and what your work touches. Not every repo on disk.
- **Security items suggest `/wbc:build`**: Why: `build` takes an upgrade that fits one PR and hands a wider one to `plan`. Not `/wbc:plan` for every item: most fixes are one bump in one repo.
- **A vulnerability is checked across every active repo, right after reviews and replies**: Why: one package tends to sit in every repo that shares a stack, and a fix left with tickets slips day after day.
- **Review files stay where `review` puts them**: Why: `daily` lists only open PRs, so a merged PR's file is never revisited, and moving files is `review`'s business. Not archiving them into `completed/`: merged PRs' files now stay in `.ai/reviews/`.
- **No `## Recap` fallback**: Why: no notes still use one, and `setup` no longer migrates it. Not reading an old `## Recap` section for the notes file.
- **Plans are saved only in the notes file**: Why: it's the one place you already chose for your day. Not under `~/.claude/`, which Claude Code protects, or a repo's `.ai/`, since `daily` isn't tied to one repo.
