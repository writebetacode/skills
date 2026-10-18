`findings.md`, for someone who saw none of this:

```
# <the problem, one line>

## Problem

<restated; how to reproduce it, or why you couldn't>

## Timeline

- <time>: <what happened> [citation]

## Impact

<who or what it hit, how badly, for how long>

## What we checked

- <step>: <what it showed> [citation]

## What it means

<how the evidence fits together>

## Likely cause

<cause> [citation]. Proof: <the experiment and its before/after | none: why>. Confidence: <high | medium | low>: <the checker's verdict and why>. A starting point, not a verdict.

## Ruled out

- <cause>: <why> [citation]

## Ways to fix

1. <fix>: <trade-off>
2. <fix>: <trade-off>

Recommended: <N>, <why>.

## Not checked

- <what>: <why>
```

Timeline and Impact: incidents only; otherwise leave both out. Other empty sections: "None."

Reply: the findings path; the likely cause and confidence in 1–2 sentences. Called by `plan` → that's all. Else: the fix fits one PR with no open design choices → suggest `/wbc:build <findings path>`; else `/wbc:plan <findings path>`.
