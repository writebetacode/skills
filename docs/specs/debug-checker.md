# Debug checker

The debug checker challenges a claimed bug cause against its evidence in a fresh context, so a cause that only fits the evidence doesn't pass as proven. It judges and changes nothing.

## Context

`research` investigates bugs and hands the checker the problem, the claimed cause with its proof, the evidence notes and the repo, and nothing of the conversation behind them.

## Scope

In: who calls it.
Out: everything else the checker does, until a change touches it; calls from `plan`.

## Decisions

- **`research` is its only caller**: Why: debugging moved from `plan` to `research`. Not `plan`, which now hands bugs to `research`.
