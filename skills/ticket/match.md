Before every create, search the project you're filing in (the repo; Jira: the project), every state, for the same problem or request by its key terms: `list` with `--search` and every state; Jira: `search`, `--jql 'project = <KEY> AND text ~ "<terms>"'`. Tickets this request files or names (its parent, the siblings it files, tickets it links) never count. On the closest match:

- Open, the same problem → comment the new case on it, changing nothing else; file nothing.
- Closed, same or related; or open and only related → file the new ticket, linked to it as related.
- None → file as asked.

The comment refused → file the new ticket with a `Related:` body line naming the match. The search fails → file as asked, and say the search didn't run, with the tracker's error. Reply: what you did, and each ticket you touched with its link.
