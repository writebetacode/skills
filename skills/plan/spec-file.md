`specs/<area>.md`: one per domain area (skill, agent, app area: `payments`), named for it, never for a plan or change; `docs/specs/` is flat. Every change to an area updates its spec. For readers who never saw the conversation, tickets or research: what it does, as users and callers see it, and why. Never how it's built (components, code layout, internal interfaces, storage, tests, repos, upgrades): tasks hold it. ✗ `LockoutService in auth/ stores the lock time in Redis` ✓ `A locked-out user sees when they can try again`. Links to nothing; no code or ticket keys. Omit sections with nothing to say.

- Area with a spec: its base version, rewritten to read as today's truth and to these rules (a Design section: its what and why → other sections; the rest goes); each overturned Decision → the new one and why. New area: only what this change defines.

````
# <Area>

<2–3 sentences: what it does, for whom, why.>

## Context

<Where it fits: areas and people it works with, constraints.>

## Scope

In: <…>
Out: <…; each behaviour this change removes>

## Behaviour

```gherkin
Scenario: <observable outcome>
  Given <state>
  When <action>
  Then <what a user or caller sees>
```

## Decisions

- **<Topic>**: <decision>. Why: <reason>. Not <alternative>: <why>.

## Questions

- <question raised along the way> → <answer | Open: <assumption>>
````

- Only what matters: behaviour a test already pins stays out unless it's arbitrary; one scenario per behaviour, never one per edge case.
- Decisions: only arbitrary ones and ones a later change could undo without knowing why. A bug's proven cause → the why of the Decision it shapes.
- Scenarios state behaviour, never test construction: ✗ `Given UserRepo is mocked` ✓ `Given no account for that email`. Several cases → `Scenario Outline` + `Examples`.
