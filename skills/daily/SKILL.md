---
name: daily
description: Plan your day from what's waiting on you across GitHub, GitLab, Jira and connected tools like Slack, or recap a day's work as bullets in the terminal or your notes. No argument plans today; `recap`, optionally with a day, recaps.
disable-model-invocation: true
---

No argument → Plan. `recap`, optionally a day → Recap that day (today if none; local time).

Sources: `## Daily` in the loaded `~/.claude/CLAUDE.md`, a line each:

- `Notes:` a file path (`{date}` → YYYY-MM-DD) and an optional heading.
- `GitHub`, `GitLab: <host>`, `Jira` → [sources.md](sources.md).
- Anything else (`Slack: <tool>, <channels>`) → the connected tool it names.

No section → GitHub and Jira if their login check in sources.md passes, and each GitLab host `glab auth status --all` shows logged in; end the reply suggesting `/wbc:setup`.

Read only: change nothing but the notes file and review files (re-reviewed through `review`); never post, reply, merge or move a ticket. A source you can't reach → `Not checked: <source>: <why>` in the reply; carry on.

## Plan

1. Gather from each source:
   - Waiting on the user: review requests, unanswered mentions, threads, DMs, to-dos.
   - Active repos, for the next two: `${CLAUDE_SKILL_DIR}/active-repos.sh`, one main checkout per line.
   - PRs they reviewed, and comments on their own PRs (each unresolved thread or comment whose last word isn't theirs → Replies owed, with what it asks): [reviews.md](reviews.md).
   - Security in each active repo: [security.md](security.md).
   - Their open PRs/MRs: failing CI, changes requested, approved, conflicts.
   - Tickets assigned to them and not done, with status.
   - Leftovers: the latest earlier recap in the notes (≤7 days back): its `Carried over` list, if any. No recap → `${CLAUDE_SKILL_DIR}/sessions.sh <day>` for the last earlier day with sessions (≤7 days back), unfinished work only.
2. Invoke the `voice` skill (once per session). Show what's waiting under Reviews (re-reviewed PRs included), Replies owed, Security, Your PRs, Tickets, Carried over (empty → leave out): each item linked, then why it's there in ≤15 words.
3. Propose today's plan, numbered: unblocking others first (reviews, replies), then security fixes, then their PRs closest to merging, then tickets by priority. Each item names the skill to start it with: `/wbc:review 42`, `/wbc:build`, `/wbc:plan ABC-123`.
4. Settle it via `same-page`; show the changed plan in full outside it. Agreed → notes file set → write it per Notes as `Plan`. Reply: the plan, and the notes path if written.

## Recap

1. `${CLAUDE_SKILL_DIR}/sessions.sh <YYYY-MM-DD>`: each session that day, by start time (folder, branch, title, PRs, the skills Claude ran, the user's prompts, Claude's last reply), then the user's commits that day per repo. Plus each source's activity that day. Leave out daily's own runs.
2. Invoke the `voice` skill (once per session), then write bullets:
   - One per thing done or decided, not per session, prompt or source; merge what several say about the same thing. Commits say what shipped; prompts only what was asked.
   - Past tense, ≤15 words; the repo when there's more than one; PR and ticket numbers when known.
   - Unfinished → "Started …"; dead ends and chit-chat → left out. No secrets, paths or code.
   - ✗ `- Ran the build skill on .ai/plan/empty-cart-total; the review found 0 issues`
   - ✓ `- Fixed the empty-cart total in shop (PR #142)`
3. That day's plan (its note's `Plan` section): each item no bullet covers → a `Carried over:` list after the bullets.
4. Where: as asked; else the notes file, per Notes, as `Recap`; else the terminal.
5. Reply: the bullets; written to a file → its path too.

## Notes

The day's file, created if missing; the Notes heading in it, added at the end if missing. `Plan` or `Recap`: a section with that title, one level below that heading (no heading → `##`). One already there → replace it, up to the next heading at its level or above; else add it at the end of the heading's section (no heading → of the file). Keep the rest byte-for-byte.
