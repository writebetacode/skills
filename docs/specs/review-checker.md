# Review checker

The review checker rechecks each drafted review finding in a fresh context, stricter than the reviewer was. Only findings that hold up reach you, worded no stronger than the code shows and asked as questions, with any fix offered rather than told.

## Why

`review` drafts as hard as it can on purpose, so it overreaches: findings that don't hold, that overstate, or that tell the author what to do. Without a second, independent look, you'd be the one pushing back on each of them.

## What

`review` calls it on the findings it drafts, for a PR or for local changes, and `build` calls it on the findings of the local review it asks for each task. It gets the findings, the diff, the code, and whatever the change was reviewed against (threads, specs, the ticket, the task, findings or the request), but none of the conversation behind them. It edits no files.

## Behaviour

- It withdraws a finding unless its cited code is there, its claim holds when traced from scratch, it comes from this change, it matters, and it needs the author's answer (praise, preferences, duplicates and linter rules don't).
- It narrows an overstated finding to what the code shows.
- Blocking stays only for broken behaviour, security, breakage elsewhere, an unmet ticket criterion, or code no longer matching a spec's behaviour or Decision the change didn't update. It downgrades anything else.
- It relabels any finding not labelled issue or question.
- It rewords a finding whose ask isn't one question, or that tells a fix anywhere (even as a question), so it asks about the problem and then offers the fix as one way forward.
- It cuts an offered way forward that isn't there or wouldn't work, and fixes or drops a wrong example, keeping the finding.
- It never withdraws a thread's finding: it corrects the finding's summary of the thread, and turns a reply that doesn't hold up into a note that there's nothing to add, so nothing posts.
- It never adds findings of its own.

## Sketch

It replies with one line per finding, then every finding it didn't withdraw, word for word apart from its changes:

```text
1. kept: an empty cart reaches the null total
2. downgraded: a missing test isn't broken behaviour
3. withdrawn: the code had this before the change
```

## Decisions

- **The blocking bar matches `review`'s**: Why: `review` blocks unmet criteria and spec mismatches, and a checker with an older bar would quietly undo that.
- **Only `review` and `build` call it**: Why: `daily` reaches it only through `review`. Not a direct call from every skill whose work it touches.
- **Its result is final**: Why: a reviewer who argues with the checker brings back the bias it was there to remove. Not a second round with the reviewer.
- **Overstated findings are narrowed, and ones that don't ask are reworded, not withdrawn**: Why: the problem under the wording is still real, and the reviewer drafts boldly on purpose.
- **Thread findings are never withdrawn**: Why: every open thread keeps its finding, so you can see it was read. Not dropping the thread from the review.

## Out of scope

- How `review` drafts findings and finds spec mismatches.
