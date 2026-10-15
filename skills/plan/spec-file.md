`specs/<area>.md`: one per domain area (skill, agent, app area: `payments`), named for it, never for a plan or change; `docs/specs/` is flat. Every change to an area updates its spec. For readers who never saw the conversation, tickets or research: the complete what and why, enough to build it from alone. Links to nothing; no code or ticket keys. Omit sections with nothing to say.

- Area with a spec: its base version, rewritten where it changes to read as today's truth; each overturned Decision → the new one and why. New area: only what this change defines.
- No area (a research request) → `spec.md`: the question, answer and why; Behaviour and Design only for a deliverable it asks for.

````
# <Area>

<2–3 sentences: what it does, for whom, why.>

## Context
<What it builds on: the code, repos and constraints involved.>

## Scope
In: <…>
Out: <…>

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

- Decisions: every one made along the way, here and nowhere else. A bug's proven cause → the why of the Decision it shapes.
- Scenarios state behaviour, never test construction: ✗ `Given UserRepo is mocked` ✓ `Given no account for that email`. Several cases → `Scenario Outline` + `Examples`.
