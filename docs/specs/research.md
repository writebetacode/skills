# Research

`research` finds something out and reports it with citations, changing nothing. Something broken gets a proven cause and ways to fix it, in a findings file you hand to `plan` or `build`.

## Why

Before you decide, you need to know how things work here, not generic advice. When something breaks, a cause that only fits the evidence sends the fix to the wrong place.

## What

It answers from the code, docs, the web and connected tools, preferring the repo's patterns and the versions its lockfiles pin. For a bug, it also uses the repo's `## Debug tools` and `## Related repos` lists.

`plan` and `prompt-writer` hand it questions already agreed with you. `plan`'s include which specs an area has, in whatever folder the repo keeps them (`docs/specs`, `docs/superpowers/specs` and so on), and what the code already has that tasks should reuse. `build` hands over a test that fails in CI but passes locally.

## Behaviour

- A plain question gets a cited report in the chat: the answer, assumptions, adjacent findings and what wasn't found.
- A request with several readings gets agreed with you first, unless another skill already did.
- A question that only trying can answer gets an experiment. Its report cites each command and what it printed.
- A bug gets a folder with the failing path walked step by step, each step cited or marked assumed, plus findings anyone can follow: the cause, its proof and confidence, and ways to fix it, one recommended.
- A separate debug checker agent challenges each cause. Its verdict sets the confidence, at most medium for one that won't reproduce. Research checks the gaps it names, at most twice, and drops a cause it rejects.
- Outside the repo it only reads, it redacts secrets and personal data, and never makes a branch.
- Asked by you, it replies with the findings' path and cause, suggesting `build` for a fix that fits one PR with nothing left to decide, or `plan` otherwise.
- A test from `build` runs alone up to 50 times. If it never fails, it runs in the whole suite, in CI's order, up to 5 times. A failure is rerun at the PR's base to tell whether the PR caused it. Other PRs' findings for that test are leads, never the answer.
- If a handed-over test never fails here, it looks for a difference between CI and your machine.

## Decisions

- **Questions and bugs**: one skill, outside `plan`, which only plans. Why: both find something out and report it, changing nothing, and each skill costs a description in every session.
- **Findings folder**: `.ai/research/<name>/` in the main checkout, not the plan folder. Why: you hand findings over by path, and a bug may need no plan.
- **Plain questions**: no files. Why: the report is the answer.
- **Experiments and proofs**: in a throwaway worktree, deleted after. Why: some answers show up only when you try; your checkout stays as it was, and a prototype is built to answer, not to ship.
- **Proof**: the failure goes away with only the cause patched out. Why: evidence that fits isn't proof.
- **Flaky test runs**: 50 alone, then 5 of the suite. Why: 50 catches a 1-in-20 flake with high odds and is quick for one test. Suite runs catch flakes that need other tests first.
- **A handed-over failure**: rerun at the PR's base. Why: whether the PR caused it decides where the fix goes.

## Out of scope

- Fixing anything, planning the fix or building it.
