# Review

`review` gives you a careful review of a pull or merge request that you edit before anyone sees it, and it holds every PR to the repo's specs, so code and specs never drift apart: wherever the code no longer matches a spec the PR didn't update, the PR is blocked with a question.

## Context

Specs in `docs/specs/` are the living definition of each domain area, and every change to an area updates its spec in the same change. They're written by area, not indexed by the files they cover. `review` reads a PR as it stands at its head, so a spec the PR changed reads as changed, and keeps its findings in a gitignored review file in the main checkout until you say to post. It reads related repos from the main checkout's `CLAUDE.md` and `CLAUDE.local.md`, wherever it runs. It looks as hard as it can for anything that should change, sets aside each finding that isn't worth the author's time, and has a checker agent recheck the rest in a fresh context to rein that in. On PRs you review, it keeps a reply ready for every open thread, whoever started it; a request to address comments on your own PR goes to `build`. `build` runs a local review of its own uncommitted changes through `review`, after writing its plan's specs into `docs/specs/`.

## Scope

In: findings as issues or questions, each asked warmly as a question, offering a known way forward when there is one; specs in the review's context; spec mismatches as blocking findings; following each name the change touches to every place that uses it, here and in each related repo; the PR's link at the top of the review file; links from each line a finding cites to that line at the commit it reviewed; a finding and a ready reply for every open thread; scoring each drafted finding as worth posting or not, and listing those that aren't under Withdrawn; never raising a withdrawn finding again; the README's `review` section, which says it holds PRs to the repo's specs.
Out: praise, and comments that ask for nothing; suggestion, nitpick, todo and chore labels; telling the author what to do, even as a question; reviewing a spec on its own; specs whose area the diff doesn't touch; how the review checker treats findings (the review-checker spec); moving back an archived review file; checking a PR's author to send comments on your own PR to `build`.

## Behaviour

```gherkin
Scenario: The specs a PR is held to
  Given a PR changes how long checkout sessions last
  When you review the PR
  Then it's held to each spec in docs/specs/ whose text shares the diff's key terms (skill and feature names, behaviours, settings, paths)
  And it reads those specs as the PR leaves them, or as your checkout has them for a local review

Scenario: A PR that contradicts a spec is blocked
  Given docs/specs/auth.md says sessions last 1 hour
  And a PR makes sessions last 24 hours without changing auth.md
  When you review the PR
  Then a blocking finding asks: "auth.md says sessions last 1 hour. Should it say 24 now, or should this stay at 1?", citing auth.md's line

Scenario Outline: Work a later PR of the plan will do isn't flagged
  Given auth.md already says 24 hours, and <later> names the later work that makes it so
  And this change keeps sessions at 1 hour
  When <review>
  Then there is no finding about the session length

  Examples:
    | later                                     | review                         |
    | the PR's merge order                      | you review the PR              |
    | build, in asking for the local review     | build reviews its own changes  |

Scenario: A spec updated with the code is fine
  Given a PR makes sessions last 24 hours and changes auth.md to say 24 hours
  When you review the PR
  Then there is no finding about auth.md

Scenario: Build's own reviews check specs too
  Given build's uncommitted changes contradict docs/specs/auth.md
  When build reviews them before you commit
  Then the review finds the same blocking mismatch

Scenario Outline: A break outside the diff is found
  Given a PR <change>
  And <where it breaks>
  When you review the PR
  Then a blocking finding names that place

  Examples:
    | change                                              | where it breaks                                                        |
    | renames the env var CART_TTL to CART_TTL_SECONDS    | the deploy config still sets CART_TTL                                  |
    | makes orders.email required                         | orders saved before have no email, and the migration doesn't fill one  |
    | renames the cart API's userId field to accountId    | a related repo's checkout page still reads userId                      |

Scenario: A break in a related repo survives the checker
  Given the review finds a related repo still reading a field the PR renamed
  When the checker rechecks the finding
  Then it reads that repo's code, and the finding stays

Scenario Outline: A finding asks about the problem and offers a known way forward
  Given a PR's handler throws when there's no user
  And <what the repo has>
  When you review the PR
  Then the finding is an issue asking "What would you like to happen here when there's no user?"
  And <what it offers>
  And it never tells the author what to do, such as "Could you add a null check here?"
  And its example shows only the problem

  Examples:
    | what the repo has                                       | what it offers                                                    |
    | requireUser() in auth.ts already returns early for that | requireUser() as one way forward, for the author to take or leave |
    | nothing that handles a missing user                     | no way forward, just the question                                 |

Scenario: A finding not worth posting is set aside before the checker
  Given a PR adds a log line that could also say which cart it's for
  When you review the PR
  Then the finding about the log line goes under Withdrawn in the review file, saying why it isn't worth posting
  And the checker never sees it, and it never posts

Scenario Outline: A withdrawn finding stays withdrawn
  Given <who> put a finding about the log line under Withdrawn
  When the PR gets a new push and review re-reviews it
  Then no new finding about the log line appears

  Examples:
    | who        |
    | you        |
    | the review |

Scenario: The review file links its PR
  When you review PR 42
  Then the review file's title links to PR 42

Scenario: A finding links the lines it cites
  Given a finding cites auth.md's session rule and the requireUser() helper
  When you review the PR
  Then it names each, linking to its lines on GitHub or GitLab at the commit it reviewed
  And each link sits on the words naming it, never on a citation added after them, like "(:248)"

Scenario Outline: Every open thread gets a finding
  Given an open thread on the PR, started by <who>
  And <where it stands>
  When you review or re-review the PR
  Then the review file has a finding for the thread that says where its conversation stands
  And <what it holds>

  Examples:
    | who        | where it stands                                                  | what it holds                                                  |
    | you        | the author says empty carts never reach checkout, but they can   | a reply showing how an empty cart gets there                   |
    | a teammate | the latest commit fixes what they asked for                      | a reply naming the commit that fixed it                        |
    | a teammate | the author's answer holds and there's nothing new to say         | a note that there's nothing to add, which never posts          |

Scenario: Replies are current when they post
  Given a thread got a new comment, or was resolved, after the review file was written
  When you say "post it"
  Then review re-reviews the PR and stops for you to look again, posting nothing
```

## Decisions

- **Every spec mismatch is blocking, asked as a question**: A finding blocks for broken behaviour, security, breakage elsewhere, or code that no longer matches a spec's scenario or Decision the PR didn't update. Why: specs must always match the code, and either fix is small. Not non-blocking for improvements: a stale spec misleads the next plan just the same.
- **Either fix clears it, with no reason required**: Why: what matters is that code and spec agree. Not demanding the PR explain every spec edit.
- **Comments on your own PR go to `build`**: Why: `review` keeps replies ready on PRs you reviewed. Not a check in `review` that reads your login to route them.
- **Review files stay in `.ai/reviews/`**: Why: nothing archives them any more (`daily` doesn't), so there's nothing to move back. Not moving files out of `completed/`.
- **Specs found by area, not path**: Why: specs aren't indexed by the files they cover. Not a path index every spec would have to keep up.
- **Every open thread gets a finding, whoever started it**: Why: you see where each conversation stands, with a reply ready, without having to ask. Not only replies to your own comments: a teammate's open thread holds up the PR just as much.
- **Nothing new to say is said, and never posted**: Why: a reply that repeats the thread is noise for the author, and a missing finding would leave you wondering whether the thread was read. Not leaving such threads out of the file.
- **Draft hard, then rein it in**: Why: a reviewer that holds back while drafting misses real problems, and a checker in a fresh context cuts what doesn't hold and tones down what's overstated, so you never have to push back on a finding to get it right. Not a cautious first draft.
- **Findings not worth posting are set aside before the checker**: Why: a finding can hold up and still not be worth the author's time, and weighing each one as soon as it's drafted spares the checker and the author both. Not a pass after the checker, and not dropping it unseen: it's listed under Withdrawn with why, so you can see what was set aside.
- **Withdrawn stays withdrawn**: Why: a re-review that raises a withdrawn finding again makes you withdraw it again after every push. Not judging it afresh on each re-review.
- **Every name the change touches is followed to every use**: Why: a break outside the diff is the easiest to miss, and the checker only cuts findings, so nothing later catches what this skips. Not only callers and tests, and not a list in the review file of what was followed: the file changes only by gaining findings.
- **Every related repo is searched**: Why: judging from a repo's description whether a change reaches it is how a consumer gets missed. Not only the repos whose description matches the diff.
- **Every finding is an issue or a question, asked warmly as a question**: Why: a review should start a conversation, the way a good mentor would, and it's there to find what needs to change. Not suggestion, nitpick, todo or chore labels, praise, thoughts or notes, and never a fix the author is told to make, even one worded as a question: the author decides how to fix it.
- **A known way forward is offered, never pushed**: Why: when the repo already has an answer, like a helper that does the job, pointing to it saves the author time, and offering it after the question leaves the choice with them. Not withholding what the review knows, and not a way forward the code doesn't back.
