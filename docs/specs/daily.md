# Daily

`daily` lets you start your day knowing what's waiting on you and end it with a recap you don't have to write. In the morning it gathers what needs you across your hosts, trackers and chat, keeps your reviews current, flags security issues across the repos you work in, and helps you settle a plan; a recap turns a day's sessions, commits and activity into short bullets.

## Context

Only you start `daily` (`/wbc:daily`, or `/wbc:daily recap [day]`). Its sources are a `## Daily` section in your global `~/.claude/CLAUDE.md`, which `setup` writes: `GitHub`, `GitLab: <host>` and `Jira` are read through their CLIs; anything else (`Slack: <connector>, <channels>`) through the connected tool it names; an optional `Notes:` line names your notes file, with `{date}` for the day, and a heading to write under.

`review` keeps a PR's findings in a gitignored review file in the repo's main checkout. Running it again re-reviews new pushes and replies, or says the file is current; nothing posts until you say so.

## Scope

In: the morning plan and the recap; sources and the notes file; re-reviewing PRs you reviewed, through `review`; new comments on your PRs; security alerts and dependency-update PRs across active repos; the README's `daily` section, which mentions re-reviews through `review`, comments on your PRs and security items.
Out: posting, commenting, merging, fixing or moving tickets; first reviews; recaps longer than a day; calendars; archiving review files; reading an old `## Recap` section; hidden markers around the plan and recap in your notes.

## Behaviour

```gherkin
Scenario: Only you start it
  Given a session where nobody typed /wbc:daily
  Then Claude never runs daily on its own

Scenario: Morning: what's waiting on you
  Given your Daily section lists GitHub, Jira and the Slack connector
  And PR 42 asks for your review, CI failed on your PR 45, and a Slack DM to you has no reply
  When you run /wbc:daily
  Then it lists PR 42 to review, PR 45's failing CI, the Slack DM, and your open Jira work items with their status, grouped by kind
  And each line links to the thing and says why it's there

Scenario: Morning: settle the plan
  Given daily has listed what's waiting
  When it proposes today's plan
  Then it's a numbered list, without checkboxes
  And reviews and replies come first, then security fixes, then your PRs closest to merging, then tickets by priority
  And each item names the skill to start it with, like "/wbc:review 42"
  And it settles the plan with you one question at a time
  And when a notes file is set, the plan you agree goes into today's note as a Plan section under your notes heading, replacing an earlier plan for that day

Scenario Outline: Morning: yesterday's leftovers
  Given <yesterday>
  When you run /wbc:daily
  Then "Finish ABC-123" is in the list

  Examples:
    | yesterday                                                            |
    | yesterday's recap carried over "Finish ABC-123"                      |
    | there's no recap, and your last day's sessions left ABC-123 unfinished |

Scenario: Re-review a PR you reviewed with review
  Given you reviewed PR 50 in shop, an active repo, with review, so shop's main checkout has .ai/reviews/50.md
  And its author has since pushed a fix
  When you run /wbc:daily
  Then it runs review on PR 50 in shop, which updates its review file
  And PR 50 is listed under Reviews with what changed and "/wbc:review 50" to look it over and post
  And nothing is posted

Scenario: A re-review that stops
  Given review stops partway through re-reviewing PR 50
  When daily carries on
  Then it says why PR 50 wasn't re-reviewed and moves on to the next PR

Scenario Outline: A PR you reviewed without review
  Given you reviewed PR 60 on the web, so there's no review file, and it <activity>
  When you run /wbc:daily
  Then PR 60 is <result>, and no review runs

  Examples:
    | activity                          | result                                    |
    | has pushes since your review      | listed with "/wbc:review" and its link    |
    | has nothing new since your review | not listed                                |

Scenario: PRs you reviewed on GitLab
  Given an open GitLab MR names you as reviewer
  When you run /wbc:daily
  Then it counts as one you reviewed, and pushes since your latest note or approval count as new

Scenario: New comments on your PRs
  Given a reviewer left 3 comments on your PR 45, each in a thread whose last word isn't yours
  When you run /wbc:daily
  Then each comment is listed with what it asks of you

Scenario: Security issues across active repos
  Given shop has an open alert for a lodash vulnerability, and web and api lock the same affected lodash
  And shop had a session this week, and web and api are its related repos
  When you run /wbc:daily
  Then one item lists shop, web and api together, suggesting /wbc:build to fix them
  And alerts of any severity count, as do open Dependabot or Renovate PRs

Scenario: GitLab vulnerabilities hidden by its tier
  Given api is on GitLab, on a tier that doesn't show vulnerabilities
  When you run /wbc:daily
  Then it says api's vulnerabilities weren't checked

Scenario: Recap
  Given today you merged PR 42, moved ABC-123 to Done and edited a Confluence page, partly in Claude Code sessions
  When you run /wbc:daily recap
  Then it reads today's Claude Code sessions, your commits in the repos they touched, and each source's activity
  And you get one past-tense bullet per thing done or decided, 15 words or fewer, merged across sessions, commits and hosts
  And the bullets hold no secrets, paths or code, and leave out daily's own runs
  And plan items with no matching bullet are listed as carried over

Scenario Outline: Where the recap goes
  Given <setting>
  When you run /wbc:daily recap
  Then it goes <where>

  Examples:
    | setting                          | where                                                                                     |
    | you ask for it somewhere         | where you asked                                                                           |
    | a notes file is set              | into the note as a Recap section under your notes heading, replacing an earlier recap of that day |
    | no notes file is set             | to the terminal                                                                           |

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

## Decisions

- **One skill for the morning and the recap**: Why: they read the same sources, and the recap compares against the morning's plan.
- **Only you start it; modes by argument, not clock**: Why: you decide when your day starts and ends.
- **Sources in your global `~/.claude/CLAUDE.md`**: Why: `daily` covers all your repos, so per-repo files don't fit, and the other skills already read config from `CLAUDE.md` sections.
- **Writes only your notes file, plus review files through `review`, a review's fetched refs and throwaway worktrees aside**: Why: it runs across every repo and tracker you have; acting is for the skill named next to each plan item.
- **Re-reviews go through `review`, which decides if anything changed**: Why: one place decides whether a review is current. Not `daily` checking heads and threads itself: a second copy of `review`'s rule.
- **Re-reviews run in your `daily` session, one PR at a time**: Why: `review` starts the review checker, which a subagent can't do. Not a subagent per PR.
- **Re-reviews only where a review file exists**: Why: a re-review updates work you started; a first review is a bigger job you should ask for.
- **Active repos are the main checkouts of the past 7 days' sessions, temp folders aside, plus their related repos**: Why: that's where you work and what your work touches. Not every repo on disk.
- **Security items suggest `/wbc:build`**: Why: `build` takes an upgrade that fits one PR and hands a wider one to `plan`. Not `/wbc:plan` for every item: most fixes are one bump in one repo.
- **A vulnerability is checked across every active repo, right after reviews and replies**: Why: one package tends to sit in every repo that shares a stack, and a fix left with tickets slips day after day.
- **Review files stay where `review` puts them**: Why: `daily` lists only open PRs, so a merged PR's file is never revisited, and moving files is `review`'s business. Not archiving them into `completed/`: merged PRs' files now stay in `.ai/reviews/`.
- **No `## Recap` fallback**: Why: no notes still use one, and `setup` no longer migrates it. Not reading an old `## Recap` section for the notes file.
- **Plans are saved only in the notes file**: Why: it's the one place you already chose for your day. Not under `~/.claude/`, which Claude Code protects, or a repo's `.ai/`, since `daily` isn't tied to one repo.
- **The plan and recap are headed sections in your notes**: Why: the notes are yours to read and edit, and a heading is enough for a rerun to find and replace what it wrote that day. Not hidden comment markers, which clutter the note in an editor.
- **The plan is numbered, never checkboxes**: Why: it's an order to work through, and the recap, not ticking boxes, records what got done. Not a task list to check off.
