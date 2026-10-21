# Daily

`daily` is for starting your day knowing what's waiting on you, and ending it with a recap you don't have to write. `/wbc:daily` gathers what needs you and settles a plan; `/wbc:daily recap [day]` turns a day's work into bullets.

## Why

What needs you is spread across hosts, trackers, chat and this week's repos, and reviews you started go stale as authors push. Writing up a day means piecing it together from sessions and commits.

## Behaviour

- Claude never starts it on its own.
- The morning lists what's waiting, each linked with why: reviews, replies owed, security, your PRs, tickets, and leftovers from your last recap or last day's sessions.
- A PR you reviewed with `review` is re-reviewed into its review file, ready to post; one reviewed otherwise is listed once it has new pushes.
- Unanswered comments on your PRs are listed with what each asks.
- Security alerts of any severity and Dependabot or Renovate PRs in your active repos are listed, one item per vulnerable package.
- It proposes a numbered plan (reviews and replies, security, your PRs closest to merging, then tickets by priority), each item naming the skill that starts it, settled with you one question at a time.
- The recap is a past-tense bullet of 15 words or fewer per thing done or decided, with no secrets, paths or code; plan items it misses carry over.
- With a notes file set, the plan and recap go into that day's note, unless you ask for the recap elsewhere.
- A source it can't reach is named as not checked.
- With no sources set, it reads the CLIs you're logged in to and suggests `/wbc:setup`.
- It never posts, replies, merges or moves a ticket.

## Sketch

`{date}` becomes the day; a source beyond GitHub, GitLab and Jira names its connected tool.

```md
## Daily
- Notes: ~/vault/Daily/{date}.md, under `## Claude`
- GitHub
- Jira
- Slack: Slack connector; DMs and mentions in #shop-dev
```

## Decisions

- **Morning and recap in one skill, picked by argument**: Why: they share sources, the recap checks the morning's plan, and you decide when your day starts and ends.
- **Sources in your global `~/.claude/CLAUDE.md`**: Why: `daily` spans all your repos.
- **Writes only your notes file, and review files through `review`**: Why: it spans every repo and tracker; acting is for the skill each plan item names. Not plans under `~/.claude/`, which Claude Code protects.
- **Plan and recap as headed sections of your note, the plan numbered**: Why: the note is yours to edit, a heading lets a rerun replace that day's, and the recap, not checkboxes, records what got done.
- **Re-reviews only where a review file exists, through `review`, one at a time in your session**: Why: a first review is a bigger job you ask for, `review` alone decides whether one is current, and its checker agent can't start from a subagent.
- **Active repos: the main checkouts of the past 7 days' sessions, plus their related repos**: Why: it's where you work and what that touches.
- **Security right after reviews and replies, checked across every active repo, fixed with `/wbc:build`**: Why: one package tends to sit in every repo sharing a stack, a fix left with tickets slips, and most fixes are one bump.
- **Review files stay where `review` puts them**: Why: `daily` lists only open PRs, and moving files is `review`'s job.

## Out of scope

- Recaps longer than a day, calendars, and reading old `## Recap` sections.
