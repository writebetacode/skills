# PR

`pr` lets you open, update or merge a pull or merge request without hand-writing its title and description: one PR for one branch, opened, updated, drafted, readied and merged. It never splits a branch or comments on its size, since deciding how to split work is planning.

## Context

`pr` works on the current branch's PR on GitHub or GitLab. It matches the repo's title style, fills the repo's template, squashes on merge by default, and takes a base and merge order from its caller for stacked PRs.

## Scope

In: the one-PR, one-branch rule; handing split requests to `plan`; the README's `pr` section.
Out: everything else `pr` does, until a change touches it.

## Behaviour

```gherkin
Scenario: One PR at a time
  Given a branch that changes 40 files across three concerns
  When you ask pr to open it
  Then it opens one PR
  And it says nothing about the PR's size or splitting it

Scenario: A request to split goes to plan
  When you ask pr to split feat/big-cart
  Then it hands the request to plan and opens nothing
```

## Design

One line in `pr`: it handles one PR on one branch, never splits it or comments on its size, and hands a request to split a branch to `plan`. The README's `pr` section says the same.

Testing: the repo's check script and markdownlint; opening a PR from a sample branch that touches many files across several concerns.

## Decisions

- **`pr` never splits or sizes a PR**: Why: its one job is a single PR's create, read, update and merge; splitting means deciding pieces, which is planning. Not a size warning in `pr`: it would push you to split, which is `plan`'s call, and `pr` can't act on it.
