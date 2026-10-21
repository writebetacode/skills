`specs/<area>.md`: one per domain area (a skill, `payments`), named for it, never for a plan or change; every change to an area updates it. A white paper for people (the voice line applies), read in minutes without the conversation or research: what the area does as users and callers see it, why, and how it behaves. Never how it's built (components, code layout, interfaces, storage, tests, repos, upgrades: tasks) or ACs (tickets). ✗ `LockoutService in auth/ stores the lock time in Redis` ✓ `A locked-out user sees when they can try again`. No links or ticket keys; code only in Sketch. Omit empty sections.

- Area with a spec: its base version, rewritten as today's truth to these rules (other sections, scenarios, ACs: their what and why → these; the rest goes); each overturned Decision → the new one and why. New area: only what this change defines.

````
# <Area>

<2–3 sentences: what, for whom, why.>

## Why

<The need: who has it, its cost today.>

## What

<The feature set; the areas and people it works with.>

## Behaviour

- <one thing a user or caller sees>

## Sketch

<Only if it helps picture it: an endpoint, type, payload or command, a few lines; never a full API.>

## Decisions

- **<Topic>**: <decision>. Why: <reason>. Not <alternative>: <why>.

## Out of scope

- <…; each behaviour this change removes>

## Questions

- <question raised> → <answer | Open: <assumption>>
````

- Under ~600 words.
- Behaviour: one line per thing a user or caller would notice, never per edge case or test; one a test pins → out unless arbitrary.
- Decisions: only arbitrary ones and ones a later change could undo without knowing why. A bug's proven cause → the why of the Decision it shapes.
