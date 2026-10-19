# PR

`pr` lets you open, update or merge a pull or merge request without hand-writing its title and description: one PR for one branch, opened, updated, drafted, readied and merged. It never comments on a PR's size, since deciding how to split work is planning.

## Context

`pr` works on the current branch's PR on GitHub or GitLab. It matches the repo's title style, fills the repo's template, squashes on merge by default, and takes a base and merge order from its caller for stacked PRs. A request to split a branch goes to `plan`, not `pr`. `build` cleans up merged branches the same way when it closes a plan.

## Scope

In: the one-PR, one-branch rule; cleaning up after a merge; the README's `pr` section, which says it handles one PR per branch, never sizes it, and deletes a local branch only once all its work has merged.
Out: everything else `pr` does, until a change touches it.

## Behaviour

```gherkin
Scenario: One PR at a time
  Given a branch that changes 40 files across three concerns
  When you ask pr to open it
  Then it opens one PR
  And it says nothing about the PR's size or splitting it

Scenario Outline: Cleaning up after a merge
  Given you merged PR 12 from feat/abc-12-login with pr, in <where>
  When the merge is done
  Then pr <moves>, and deletes feat/abc-12-login once it's fully merged and checked out nowhere
  And a branch it keeps is named, with why

  Examples:
    | where                                                    | moves                                            |
    | shop's main checkout, with no uncommitted changes        | switches to the default branch and pulls         |
    | a linked worktree of shop                                | only fetches with pruning, staying on its branch |
    | shop's main checkout, with uncommitted changes           | only fetches with pruning, staying on its branch |
    | shop's main checkout, with the default branch checked out elsewhere | only fetches with pruning, staying on its branch |

Scenario: A squash-merged branch counts as merged
  Given PR 12 was squash-merged, so feat/abc-12-login's commits aren't on the default branch
  When pr cleans up after the merge
  Then it deletes feat/abc-12-login, since merging it into origin's default branch, as just fetched, would change nothing

Scenario Outline: A failed step keeps the branch
  Given <step> fails during cleanup
  When pr cleans up after merging PR 12
  Then feat/abc-12-login is kept, and pr says <why>

  Examples:
    | step                                        | why                         |
    | fetching from origin                        | why the fetch failed        |
    | checking the merge, on git older than 2.38  | it needs git 2.38 or later  |
```

## Decisions

- **`pr` never sizes a PR**: Why: a size warning pushes you to split, which is `plan`'s call, and `pr` can't act on it.
- **`pr` and `build` clean up merged branches the same way**: Why: both delete merged branches, including squash merges, which a plain `git branch -d` refuses. Not two ways that can drift apart.
