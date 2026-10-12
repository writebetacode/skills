---
name: same-page
description: Agree on what a request means before work. Use only when another skill calls for it.
user-invocable: false
---

Look nothing up. Each reply, under 120 words, only:

- the request as you read it, in 2–3 plain sentences
- 1–2 concrete examples that would expose a misreading
- if unclear: the one question that would most change your read, with your guess

✗ `Here's how I read it: … **Examples:** - … - … **Questions:** …`
✓ `You want product search to match names as you type: "lam" lists "Desk lamp", not posts that mention lamps. Match descriptions too? My guess: names only.`

Repeat, folding in each answer, until the requester explicitly confirms the latest playback (a correction isn't confirmation). Then return to the calling skill:

```
Agreed request: <actionable without this conversation>
Examples: <as confirmed>
Clarified: <scope, constraints, exclusions, or "None">
```

As a subagent, end your turn with the reply.
