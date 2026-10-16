# Ticket

Before `ticket` files a new ticket, it searches the same project's tickets, open and closed, and acts on the closest match: it adds your case to an open ticket about the same problem, or links a closed or merely related one. One problem stays in one place instead of spreading across duplicates.

## Context

`ticket` files, finds and updates GitHub issues, GitLab issues and Jira work items through each tracker's CLI, running commands only from its per-tracker tables, and writes directly without showing a draft first. Its tickets say what people see and why it matters, never how to fix it. Each write changes only the ticket you named, never several through a query, and adds links only when asked, except that a parent's children always get their parent.

## Scope

In: searching before every new ticket; acting on the match; a named repo other than the current folder's; the README's `ticket` section.
Out: searching before other writes; searching other repos or projects; follow-up tickets for a match in progress; editing a match's acceptance criteria; giving the match the request's parent or links; filing text another skill hands over; an install link or upgrade hint when a tracker's CLI is missing or too old.

## Behaviour

```gherkin
Scenario Outline: Ticket looks for a match before filing
  Given you file "Empty cart checkout shows 0.00"
  And <match>
  When ticket files it
  Then <result>

  Examples:
    | match                                                 | result                                                                  |
    | no ticket is about the same thing                     | it files a new ticket                                                   |
    | closed #99 is about the same problem                  | it files a new ticket linked to #99 as related                          |
    | open #120 "Cart badge count lags" is only related     | it files a new ticket linked to #120 as related                         |
    | open #142 is about the same problem                   | it comments the new case on #142 and files nothing                      |
    | you file #40's children, and #40 is open              | each child is filed under #40, with no related links to #40 or siblings |
    | the search fails                                      | it files a new ticket and says the search didn't run, with the error    |
```

## Design

Before creating a ticket, `ticket` searches the project it's filing in (the repo, or the Jira project) across every state, by the problem's key terms. Tickets this request files or names (its parent, the siblings it files, any it links) never count. On the closest match: open and the same problem → comment the new case on it, changing nothing else, and file nothing; closed, or only related → file the new ticket with a related link; none → file as asked. A comment the tracker refuses → file the new ticket, naming the match as related in its body. A related link the tracker won't take natively becomes a line at the end of the body. The reply names what it did and links each ticket it touched. The match counts as the named ticket for that comment, and the related links a match calls for need no asking.

The search step lives in its own file beside the skill, read before every create. No table reads whether a ticket is in progress. The GitHub and GitLab tables take their CLI's repo option for a named repo other than the current folder's.

The README's `ticket` section says it looks for a match before filing: an open ticket about the same problem gets your case as a comment, and a closed or merely related one gets linked.

Testing: the repo's check script, which checks every command flag against that CLI's help, and markdownlint; filing against a sample tracker with a closed, an open and a merely related match.

## Decisions

- **Every ticket in the project counts, open or closed**: Why: a closed match is history worth linking, and an open one may already hold the work. Not other projects: a match there would touch work you don't own.
- **Act on the match without asking**: Why: duplicates waste more time than a comment you can edit, and `ticket` already writes directly.
- **An open ticket about the same problem gets a comment, nothing more**: Why: the case lands where the work is, without changing a ticket someone may be building against. Not a follow-up ticket or an edit to its acceptance criteria.
- **A match it can't comment on gets a new ticket instead**: Why: the new information has to land somewhere. Not stopping to ask.
- **A failed search still files**: Why: losing the report is worse than a possible duplicate, and the reply says the search didn't run.
