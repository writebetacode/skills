# Ticket

Before `ticket` files a new ticket, it searches the same project's tickets, open and closed, and acts on the closest match: it links a related one, follows up on one in progress, or adds to one nobody has started. That keeps one problem in one place for you and whoever picks it up, instead of spread across duplicates.

## Context

`ticket` files, finds and updates GitHub issues, GitLab issues and Jira work items through each tracker's CLI, running commands only from its per-tracker tables, and writes directly without showing a draft first. Its tickets say what people see and why it matters, never how to fix it, in a fixed body: a description, steps to reproduce for bugs, and acceptance criteria. Its write rules say each write changes only the ticket you named, never several through a query, and adds links (parent, blocks, blocked by, related) only when asked, except that a parent's children always get their parent. Related links are native on GitLab and Jira and a line at the end of the body on GitHub. Each table already searches across every state.

GitHub lists the open PRs linked to an issue; GitLab lists the merge requests related to an issue; Jira groups every status into To Do, In Progress and Done.

## Scope

In: searching before every new ticket; acting on the match; the write rules this changes; the in-progress reads each table needs; a named repo other than the current folder's; the README's `ticket` section; marking "Find related tickets before filing" Done in `docs/proposed-improvements.md`.
Out: searching before edits, comments or other writes to a ticket you named; searching other repos or projects.

## Behaviour

```gherkin
Scenario Outline: Ticket looks for a match before filing
  Given you file "Empty cart checkout shows 0.00"
  And <match>
  When ticket files it
  Then <result>

  Examples:
    | match                                                         | result                                                                                   |
    | no ticket is about the same thing                             | it files a new ticket                                                                    |
    | closed #98 "Empty cart total wrong" is related                | it files a new ticket linked to #98 as related                                           |
    | closed #99 is about the same problem                          | it files a new ticket linked to #99 as related                                           |
    | open #120 "Cart badge count lags" is related, not the same    | it files a new ticket linked to #120 as related                                          |
    | open #142 about the same problem has an open linked PR        | it files a follow-up ticket with only what #142 lacks, linked to #142 as related        |
    | open #142 about the same problem is in Jira's In Progress     | it files a follow-up ticket with only what #142 lacks, linked to #142 as related        |
    | open #142 about the same problem has no open linked PR        | it adds the new case to #142's acceptance criteria and a comment, and files nothing new |
    | open #142 about the same problem, with no acceptance criteria | it adds an acceptance criteria section to #142 with the new case, and a comment         |
    | open #142 about the same problem, which you can't edit        | it files a new ticket naming #142 as related in its body                                 |
    | you file #40's children, and #40 is open                       | each child is filed under #40, with no related links to #40 or its siblings             |
    | the search fails                                              | it files a new ticket and says the search didn't run, with the tracker's error          |
```

## Design

Before creating a ticket, `ticket` searches the project it's filing in (the repo on GitHub or GitLab, the Jira project) across every state for the same problem or request, by its key terms, and acts on the closest match. Tickets this request files or names (its parent, the siblings it files, any ticket it links) never count as matches.

- Open and about the same thing, in progress → file a follow-up ticket holding only what the match doesn't already cover, with a related link.
- Open and about the same thing, not started → add the new case to its acceptance criteria (adding the section at the end of the body if it has none), comment with the new information, and file nothing.
- Closed, whether about the same thing or related → file the new ticket with a related link.
- Open and related, but not the same thing → file the new ticket with a related link.
- No match → file as before.

In progress means a linked open PR on GitHub, an open related merge request on GitLab, and the In Progress status category on Jira. When the match is updated instead of filed, it also gains any parent or links the request carried. A match the tracker won't let `ticket` edit, comment on or link → file the new ticket with the match named as related in its body. A search or in-progress read that fails → file the new ticket as before and say the search didn't run, with the tracker's error. The reply names what it did and links each ticket it touched.

Text another skill hands over with your OK (`setup`'s issue drafts) is filed exactly as given, with only the link lines added. The write rules change to match: the match a search finds counts as the named ticket for that edit and comment, one ticket per write as before, and these related links need no asking. The search-and-act step lives in its own file beside the skill, read before every create. Each tracker's table gains the in-progress read, and the GitHub and GitLab tables gain their CLI's repo option for a named repo other than the current folder's (how `setup` files on writebetacode/skills from any folder).

The README's `ticket` section says it looks for a match before filing, and the row above moves to Done.

Testing: the repo's check script, which checks every new command flag against that CLI's help, and markdownlint; filing against a sample tracker with a closed, an in-progress, a not-started and a merely related match.

## Decisions

- **Every ticket in the project counts, open or closed**: Why: a closed match is history worth linking, and an open one may already hold the work. Not open tickets only. Not other projects: a match there would link or edit work you don't own.
- **Act on the match without asking**: Why: duplicates waste more time than an update you can edit, and `ticket` already writes directly. Not a confirm step.
- **Follow up on work in progress, update work not started**: Why: changing a ticket someone's building moves their target mid-build. Not always updating the match.
- **Only the same problem gets updated; related ones get linked**: Why: folding a different problem into a ticket hides it. Not merging anything related.
- **A match it can't change gets a new ticket instead**: Why: the new information has to land somewhere. Not stopping to ask.
- **In progress means work under way, not an assignee**: Why: every new ticket is assigned to whoever files it, so an assignee says nothing about work started. Not the assignee.
- **A failed search still files**: Why: losing the report is worse than a possible duplicate, and the reply says the search didn't run. Not stopping.
- **The step in its own file**: Why: the write rules file is near its word budget, and only creates need the step. Not squeezing it into the write rules.
- **The found match counts as the named ticket**: Why: the search names it as surely as you would, and it's still one ticket per write. Not loosening the rule to query-based writes.
