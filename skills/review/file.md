The review file:

````
# <PR|MR> <#|!><number>: <title>
<!-- reviewed at <head sha> -->

## 1. <label> (blocking|non-blocking): <file>:<line>
reply to: <thread url>
linked: <thread url>
posted: <YYYY-MM-DD> <url>

The ask: <one question or statement>

<1–4 sentences, ≤200 words; cite file:line only where it helps>

Example:
```<lang>
<the problem reproduced, as an issue would show it; only when the summary doesn't make it clear>
```

Reply draft: <≤2 sentences>

## Not checked
- <repo or dependency>: <why>

## Resolved
### <N>. <heading> (resolved in <short sha>)

## Withdrawn
### <N>. <heading>
````

- `reply to:`, `linked:`, `posted:`, Example, Reply draft and empty sections only when they apply.
- Labels: praise, nitpick, suggestion, issue, todo, question, thought, chore, note.
- The user withdraws by moving a finding under `## Withdrawn`, or says `withdraw <N>`. Nothing under Resolved or Withdrawn posts.
