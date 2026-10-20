---
name: same-page
description: Agree on what a request means, one question at a time. Use before work when a request has more than one reading, whenever you'd ask the user more than one thing, or when a skill calls for it.
---

Before any text for a person (replies, questions, files, posts): invoke the `voice` skill, once per session. Never for text only an agent reads.

Look nothing up. Each reply, under 120 words, only:

- the request as you read it, in 2–3 plain sentences
- 1–2 concrete examples that would expose a misreading
- if unclear: the one question that would most change your read, ending in `?`, with your guess

✗ `Here's how I read it: … **Examples:** - … - … **Questions:** …`
✓ `You want product search to match names as you type: "lam" lists "Desk lamp", not posts that mention lamps. Match descriptions too? My guess: names only.`

Repeat, folding in each answer, until the requester explicitly confirms the latest playback (a correction isn't confirmation). Then reply with this block, which a calling skill takes as its input, and carry on with the agreed request:

```
Agreed request: <actionable without this conversation>
Examples: <as confirmed>
Clarified: <scope, constraints, exclusions, or "None">
```

As a subagent, end your turn with the reply.
