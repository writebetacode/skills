The review file:

````
# [<PR|MR> <#|!><number>](<url>): <title>

<!-- reviewed at <head sha> -->

## 1. <label> (blocking|non-blocking): <file>:<line>

reply to: <thread url>
linked: <thread url>
posted: <YYYY-MM-DD> <url>

Thread: <where it stands: who raised what, the latest word, what the head changed; ≤3 sentences>

The ask: <one question; a known way forward, if any, offered after it>

<1–4 sentences, ≤200 words; cite file:line only where it helps>

Example:

```<lang>
<the problem reproduced, as an issue would show it>
```

Reply draft: <≤2 sentences>

Nothing to add: <why, ≤15 words>

## Not checked

- <repo or dependency>: <why>

## Resolved

### <N>. <heading> (resolved in <short sha>|thread resolved)

## Withdrawn

### <N>. <heading>
````

- Example: whenever code makes the claim harder to misread. `reply to:`, `linked:`, `posted:`, `Thread:`, Reply draft, Nothing to add, empty sections: only when they apply.
- Nothing to add: replaces what would post next (an unposted thread finding's ask, summary and Example; a Reply draft); never posts.
- Labels: issue, question.
- The user withdraws by moving a finding under `## Withdrawn`, or by `withdraw <N>`. Nothing under Resolved or Withdrawn posts.
