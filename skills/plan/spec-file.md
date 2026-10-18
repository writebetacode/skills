`specs/<area>.md`: one per domain area (skill, agent, app area: `payments`), named for it, never for a plan or change; `docs/specs/` is flat. Every change to an area updates its spec. For readers who never saw the conversation, tickets or research: what it does and why, where that matters, enough to build it from alone. Links to nothing; no code, ticket keys or dependency upgrades (those are tasks). Omit sections with nothing to say.

- Area with a spec: its base version, rewritten to read as today's truth and to these rules; each overturned Decision → the new one and why. New area: only what this change defines.

````
# <Area>

<2–3 sentences: what it does, for whom, why.>

## Context

<What it builds on: the code, repos and constraints involved.>

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

## Design

<How it works: components and where they live, interfaces and data in words, errors, how it's tested, repos touched and which ships first.>

## Decisions

- **<Topic>**: <decision>. Why: <reason>. Not <alternative>: <why>.

## Questions

- <question raised along the way> → <answer | Open: <assumption>>
````

- Only what matters: behaviour a test already pins stays out unless it's arbitrary; one scenario per behaviour, never one per edge case.
- Decisions: only arbitrary ones and ones a later change could undo without knowing why. A bug's proven cause → the why of the Decision it shapes.
- Scenarios state behaviour, never test construction: ✗ `Given UserRepo is mocked` ✓ `Given no account for that email`. Several cases → `Scenario Outline` + `Examples`.
