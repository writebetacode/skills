# Ticket

`ticket` files, finds and updates GitHub, GitLab and Jira tickets from your session, for you and other skills. Its tickets say what and why, never how, and it checks for the same problem before filing.

## Why

Filing by hand means leaving your session, and the duplicate search is easy to skip, so one problem spreads across tickets. A ticket that names a fix ties whoever picks it up to a guess.

## What

It works through `gh`, `glab` and `acli`, in the current repo or one you name. `plan` and `review` read tickets through it, and `plan` writes its own with `ticket`'s templates, filing them through it when you ask.

## Behaviour

- It picks the tracker from a Jira key, a link, a tracker you name or your branch's ticket; a bare `#123` means origin's host. Otherwise it asks once.
- Lists and searches only read, showing up to 20 tickets.
- It writes straight away (a draft only if asked), asking only for what it can't work out, like a Jira project key. New tickets are assigned to you.
- Titles read `<type>: <Summary>`; on Jira, the summary alone, with the type as the work item's.
- A feature's body has Description, Why and Acceptance criteria. A bug's has Description, Steps to reproduce, Expected, Actual and Acceptance criteria. A task's is shaped like a feature's. Jira gets no checkboxes.
- Filing, or writing tickets for a plan with a tracker ticket, reads the project's three latest of that kind; when they share a shape, the new one follows it, keeping the template's content.
- Nothing it writes names causes, code, files or fixes, even when you do.
- Before filing, it searches the project's open and closed tickets. An open one about the same problem gets your case as a comment instead; a closed or only related one is linked to the new ticket. Tickets the request names, like its parent, never count.
- Links are the tracker's own where it has them, else a line ending the body, like `Related: #47`. A parent's children always get their parent; other links and labels only when you ask.
- Edits change only what you named, one ticket per write, never through a query; nothing is deleted.
- The reply says what it did and links each ticket it touched.

## Decisions

- **One template per kind**: Why: a bug needs steps and what happened against what was expected, so someone can see it; a feature needs its why.
- **The team's shape, when its latest tickets share one**: Why: tickets read like the project's own, and a ticket `plan` writes files without a rewrite.
- **What and why, never how**: Why: whoever picks it up chooses the fix.
- **Every ticket in the project counts, open or closed**: Why: a closed match is history worth linking, and an open one may already hold the work.
- **An open match gets a comment, without asking, and nothing more**: Why: duplicates cost more than a comment you can edit, and a ticket someone may be building on stays as it was.
- **A refused comment or a failed search still files**: naming the match, or saying the search didn't run. Why: losing the report is worse than a possible duplicate.

## Out of scope

- Searching before other writes, or in other projects.
- Follow-up tickets for a match, editing its acceptance criteria, or giving it the request's parent or links.
- An install link or upgrade hint when a tracker's CLI is missing or too old.
