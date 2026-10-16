Before every create, search the project you're filing in (the repo; Jira: the project), every state, for the same problem or request by its key terms: `list` with `--search` and every state; Jira: `search`, `--jql 'project = <KEY> AND text ~ "<terms>"'`. Tickets this request files or names (its parent, the siblings it files, tickets it links) never count. On the closest match:

- Open, the same problem, in progress (`in progress` row) → file a follow-up holding only what the match lacks, linked to it as related.
- Open, the same problem, not started → add the new case to its acceptance criteria (none → add that section at the body's end), comment with the new information, give it any parent or links the request carried; file nothing.
- Closed, same or related; or open and only related → file the new ticket, linked to it as related.
- None → file as asked.

The tracker won't let you edit, comment on or link the match → file the new ticket with a `Related:` body line naming it. The search or in-progress read fails → file as asked, and say the search didn't run, with the tracker's error. Reply: what you did, and each ticket you touched with its link.
