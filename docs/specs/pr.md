# PR

`pr` lets you open, update or merge a pull or merge request without hand-writing its title and description: one PR for one branch, opened, updated, drafted, readied and merged. It never comments on a PR's size, since deciding how to split work is planning.

## Context

`pr` works on the current branch's PR on GitHub or GitLab. It matches the repo's title style, fills the repo's template, squashes on merge by default, and takes a base and merge order from its caller for stacked PRs. Skill descriptions send a request to split a branch to `plan`.

## Scope

In: the one-PR, one-branch rule; cleaning up after a merge; the README's `pr` section.
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
    | where                                         | moves                                              |
    | shop's main checkout, with no uncommitted changes | switches to the default branch and pulls           |
    | a linked worktree of shop                     | only fetches with pruning, staying on its branch   |
```

## Design

One line in `pr`: never comment on a PR's size.

After a merge, `pr` runs `prune-merged.sh <branch>…` from the plugin's `bin/`, which `build` also runs when it closes a plan. In a linked worktree, or when it can't switch (uncommitted changes, the default branch checked out elsewhere), it only fetches with pruning and stays put; otherwise it switches to the default branch and pulls with pruning. Then each named branch that's checked out nowhere and fully merged, judged by whether merging it into `origin`'s default branch, as just fetched, would change nothing (so squash merges count), is deleted. A step that fails keeps the branch; nothing is deleted on a failed check. It prints each branch it keeps and why.

The README's `pr` section says it handles one PR per branch, never sizes it, and deletes a local branch only once all its work has merged.

Testing: the repo's check script and markdownlint; opening a PR from a sample branch that touches many files, and merging one.

## Decisions

- **`pr` never sizes a PR**: Why: a size warning pushes you to split, which is `plan`'s call, and `pr` can't act on it.
- **No hand-off line for split requests**: Why: the skill descriptions already send them to `plan`. Not a line in `pr` repeating the routing.
- **One cleanup script for `pr` and `build`**: Why: both delete merged branches the same way, including squash merges that defeat `git branch -d`. Not two copies of the steps.
