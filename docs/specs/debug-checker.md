# Debug checker

The debug checker challenges the claimed cause of a bug against its evidence in a fresh context, so a cause that only fits the evidence doesn't pass as proven. It judges and changes nothing.

## Why

Whoever found a cause has already read the evidence as fitting it. A second look that saw none of that reasoning catches a cause that only fits, before anyone builds a fix on it.

## What

`research` calls it while chasing a bug, handing over the problem, the claimed cause with its proof, the evidence notes and the repo, and none of the conversation behind them.

## Behaviour

- It replies with a verdict (confirmed, weakened or rejected), a confidence level, a few sentences on why, and the checks that would settle what's left.
- It rereads the evidence each claim cites, and names any other cause the evidence fits as well.
- A cause with no proof (the failure going away once only that cause is patched out) gets medium confidence at most.

## Decisions

- **Caller**: `research` only. Why: debugging moved from `plan` to `research`. Not `plan`, which now hands bugs to `research`.
