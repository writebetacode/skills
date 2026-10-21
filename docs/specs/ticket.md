# Ticket

`ticket` files, finds and updates GitHub, GitLab and Jira tickets from your session, for you and other skills. Its tickets say what and why, never how, and it checks for the same problem before filing.

## Why

Filing by hand means leaving your session. It's also easy to skip the duplicate search, so one problem spreads across tickets. A ticket that names a fix ties whoever picks it up to a guess.

## What

It works through `gh`, `glab` and `acli`, in the current repo or one you name. `plan` and `review` read tickets through it. `plan` writes its own with `ticket`'s templates and files them through it when you ask.

## Behaviour

- It picks the tracker from a Jira key, a link, a tracker you name or your branch's ticket, and otherwise asks once. A bare `#123` means origin's host.
- Lists and searches only read, showing up to 20 tickets.
- It writes straight away unless you want a draft. It asks only for what it can't work out, like a Jira project key. It assigns new tickets to you.
- Titles read `<type>: <Summary>`. On Jira it's just the summary; the type becomes the work item type.
- A feature's body has Description, Why and Acceptance criteria. A bug's has Description, Steps to reproduce, Expected, Actual and Acceptance criteria. A task's matches a feature's. Jira gets no checkboxes.
- When filing, or writing tickets for a plan with a tracker ticket, it reads the project's three latest of that kind. If they share a shape, the new one follows it, keeping the template's content.
- Nothing it writes names causes, code, files or fixes, even when you do.
- Before filing, it searches the project's open and closed tickets. An open one about the same problem gets your case as a comment instead; the new ticket links to a closed or only related one. Tickets the request names, like its parent, never count.
- Links are the tracker's own where it has them, or a line ending the body, like `Related: #47`. A parent's children always get their parent; other links and labels only when you ask.
- Edits change only what you named, one ticket per write, never through a query. It deletes nothing.
- The reply says what it did and links each ticket it touched.

## Decisions

- **One template per kind**: Why: a bug needs steps and what happened against what was expected, so someone can see it; a feature needs its why.
- **The team's shape, when its latest tickets share one**: Why: tickets read like the project's own, and you can file `plan`'s tickets as written.
- **What and why, never how**: Why: whoever picks it up chooses the fix.
- **Every ticket in the project counts, open or closed**: Why: a closed match is history worth linking, and an open one may already hold the work.
- **An open match gets a comment, without asking, and nothing more**: Why: duplicates cost more than a comment you can edit, and a ticket someone may be building on stays as it was.
- **Filing anyway after a refused comment or failed search**: naming the match, or saying the search didn't run. Why: losing the report is worse than a possible duplicate.

## Out of scope

- Searching before other writes, or in other projects.
- Follow-up tickets for a match, editing its acceptance criteria, or giving it the request's parent or links.
- An install link or upgrade hint when a tracker's CLI is missing or too old.
