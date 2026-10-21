# Review

`review` gives you a careful review of a pull or merge request, in a file you edit before anything posts. It holds each PR to its ticket's acceptance criteria and the repo's specs.

## Why

A rushed review misses breaks outside the diff and lets code drift from its specs; a noisy or bossy one wastes the author's time.

## What

It reviews a PR at its head, or uncommitted changes for `build`; a checker agent rechecks its findings in a fresh context.

## Behaviour

- Findings land in a file in the main checkout, under the PR's link, and post only on "post it".
- Each line a finding names links to that line at the reviewed commit, on the words naming it.
- Every name the change touches is followed to each use, here and in related repos; repos it can't check are listed.
- Specs come from whichever folders the repo keeps them in, matched by the diff's key terms, as the PR leaves them.
- A finding blocks only for broken behaviour, security, breakage elsewhere, an unmet ticket criterion, or code no longer matching a spec's behaviour or Decision the PR didn't update.
- Work the PR's merge order or `build`'s brief leaves to later isn't flagged.
- A spec the PR adds or changes, wherever it lives and whoever wrote it, is held to `plan`'s white-paper bar: build detail or criteria in it get a finding saying they belong in tasks or tickets. A sketched endpoint passes.
- Every open thread, whoever started it, gets a finding saying where it stands, with a reply ready or a note that there's nothing to add.
- A re-review picks up new pushes and replies, and never raises a withdrawn finding again.
- If the PR or a thread changed since the review, "post it" re-reviews and stops instead.
- A local review also checks each criterion has a test failing without the change, and the code follows the spec's Decisions and the task's how.

## Decisions

- **Spec mismatches and unmet criteria block**: Why: a stale spec misleads the next plan, and the criteria are what the PR agreed to do.
- **A spec mismatch asks which should change; either fix clears it**: Why: what matters is that code and spec agree.
- **Specs from anywhere meet `plan`'s bar, non-blocking**: Why: any spec is what later work reads, and the code can still be right.
- **Specs found by area, not path**: Why: specs aren't indexed by the files they cover.
- **Comments on your own PR go to `build`**: Why: `review` keeps replies ready on PRs you reviewed. Not a login check routing them.
- **Every open thread gets a finding, even with nothing to add**: Why: you see where every thread stands, a teammate's too. Nothing to add never posts.
- **Draft hard, set aside what isn't worth posting, then let a checker rein in the rest**: Why: holding back misses real problems, and weighing each finding as it's drafted spares the checker, which cuts what doesn't hold. Set-aside ones stay under Withdrawn, with why.
- **Withdrawn stays withdrawn**: Why: otherwise you'd withdraw it again after every push.
- **Every name is followed into every related repo**: Why: a break outside the diff is easiest to miss, and judging a repo by its description misses consumers.
- **Findings are issues or questions that ask, never tell**: Why: a review should start a conversation, as a good mentor's would; the fix is the author's call, so a known way forward comes after the question.
