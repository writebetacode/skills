The review file:

````
# [<PR|MR> <#|!><number>](<url>): <title>

<!-- reviewed at <head sha> -->

## 1. <issue|question> (blocking|non-blocking): <file>:<line>

reply to: <thread url>
linked: <thread url>
posted: <YYYY-MM-DD> <url>

Thread: <where it stands: who raised what, the latest word, what the head changed; ≤3 sentences>

The ask: <one question about the problem, never a fix to make; a known way forward, if any, offered after it>

<1–4 sentences, ≤200 words; cite only where it helps>

Example:

```<lang>
<the problem reproduced, as an issue would show it>
```

Reply draft: <≤4 sentences>

Nothing to add: <why, ≤15 words; in place of what would post next>

## Not checked

- <repo or dependency>: <why>

## Resolved

### <N>. <heading> (resolved in <short sha>|thread resolved)

## Withdrawn

### <N>. <heading>

### <a 0's heading, unnumbered>

The ask: <the ask>

Not worth posting: <why, ≤15 words>
````

- Reply draft: the thread's next message, in plain sentences, adding only context it lacks; with `reply to:`, in place of The ask, summary and Example. ✗ `issue (blocking): Does this still race?` ✓ `Still seeing this at abc123: two saves landing together both write.`
- Example: whenever code makes the claim harder to misread. `reply to:`, `linked:`, `posted:`, `Thread:`, Reply draft, Nothing to add, empty sections: only when they apply.
- Below the heading, each place cited (code, spec, existing site): a `permalink` from the host's table, at the head sha (a related repo's: its `origin/<default>` sha, under `origin`'s web URL). Link the words that name it, never an added citation: ✗ `the spec (:248, :254-:258)` ✓ `the spec's [1-hour session rule](<permalink>)`, `[requireUser()](<permalink>)`. Code only the base has: plain `file:line`.
- The user withdraws by moving a finding under `## Withdrawn`, or by `withdraw <N>`. Nothing under Resolved or Withdrawn posts.
