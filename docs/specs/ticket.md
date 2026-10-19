# Ticket

Before `ticket` files a new ticket, it searches the same project's tickets, open and closed, and acts on the closest match: it adds your case to an open ticket about the same problem, or links a closed or merely related one. One problem stays in one place instead of spreading across duplicates.

## Context

`ticket` files, finds and updates GitHub issues, GitLab issues and Jira work items through each tracker's CLI, and writes directly without showing a draft first. Its tickets say what people see and why it matters, never how to fix it. Each write changes only the ticket you named, never several through a query, and adds links only when asked, except that a parent's children always get their parent.

## Scope

In: searching before every new ticket; acting on the match; a named repo other than the current folder's; the README's `ticket` section, which says it looks for a match before filing: an open ticket about the same problem gets your case as a comment, and a closed or merely related one gets linked.
Out: searching before other writes; searching other repos or projects; follow-up tickets for a match in progress; editing a match's acceptance criteria; giving the match the request's parent or links; filing text another skill hands over; an install link or upgrade hint when a tracker's CLI is missing or too old.

## Behaviour

```gherkin
Scenario Outline: Ticket looks for a match before filing
  Given you file "Empty cart checkout shows 0.00"
  And <match>
  When ticket searches the project's tickets in every state by the problem's key terms, then files it
  Then <result>
  And the reply says what it did and links each ticket it touched

  Examples:
    | match                                                 | result                                                                    |
    | no ticket is about the same thing                     | it files a new ticket                                                     |
    | closed #99 is about the same problem                  | it files a new ticket linked to #99 as related                            |
    | open #120 "Cart badge count lags" is only related     | it files a new ticket linked to #120 as related                           |
    | open #142 is about the same problem                   | it comments the new case on #142, changing nothing else, and files nothing |
    | open #142 is about the same problem, but the tracker refuses the comment | it files a new ticket, naming #142 as related in its body |
    | closed #99 is about the same problem, and the tracker has no native related link | it files a new ticket, with a line at the end of its body naming #99 as related |
    | you file #40's children, and #40 is open              | each child is filed under #40, with no related links to #40 or siblings   |
    | the search fails                                      | it files a new ticket and says the search didn't run, with the error      |

Scenario: Tickets the request names never match
  Given you file "Empty cart checkout shows 0.00" linked to #77
  And #77 is about the same problem
  When ticket files it
  Then #77 isn't treated as a match, and the new ticket is filed linked to #77 as asked

Scenario: Filing in another repo
  Given you're in ~/code/shop
  When you file a bug in acme/web
  Then ticket searches acme/web's issues and files it there
```

## Decisions

- **Every ticket in the project counts, open or closed**: Why: a closed match is history worth linking, and an open one may already hold the work. Not other projects: a match there would touch work you don't own.
- **Act on the match without asking**: The match counts as the ticket you named for that comment, and the related links a match calls for need no asking. Why: duplicates waste more time than a comment you can edit, and `ticket` already writes directly.
- **An open ticket about the same problem gets a comment, nothing more**: Why: the case lands where the work is, without changing a ticket someone may be building against. Not a follow-up ticket or an edit to its acceptance criteria.
- **A match it can't comment on gets a new ticket instead**: Why: the new information has to land somewhere. Not stopping to ask.
- **A failed search still files**: Why: losing the report is worse than a possible duplicate, and the reply says the search didn't run.
