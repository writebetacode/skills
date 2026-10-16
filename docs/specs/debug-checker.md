# Debug checker

The debug checker challenges a claimed bug cause against its evidence in a fresh context, so a cause that only fits the evidence doesn't pass as proven.

## Context

`research` investigates bugs and hands the checker only paths: the problem, the claimed cause with its proof, the evidence notes and the repo.

## Scope

In: who calls it.
Out: everything else the checker does, until a change touches it; calls from `plan`.

## Design

`agents/debug-checker.md`, read-only, for `research` only; its description says so.

Testing: the repo's check script (the agent is named by a skill) and markdownlint.

## Decisions

- **`research` is its only caller**: Why: debugging moved from `plan` to `research`. Not `plan`, which now hands bugs to `research`.
