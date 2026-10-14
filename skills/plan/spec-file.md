`spec.md`, for readers who'll never see the conversation, tickets, findings or research: the complete what and why, enough to build it from alone. Links to nothing; no code or ticket keys. Omit sections with nothing to say. Research request → the question, the answer and why; Behaviour and Design only for a deliverable it asks for.

````
# <Title>

<2–3 sentences: what changes, for whom, why.>

## Context
<Today's behaviour; the code, repos and constraints involved; a bug's proven cause.>

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

- Decisions: every one made along the way, here and nowhere else.
- Scenarios state behaviour, never test construction: ✗ `Given UserRepo is mocked` ✓ `Given no account for that email`. Several cases → `Scenario Outline` + `Examples`.
- Epic spec: Design lists its features in build order, one line each.
