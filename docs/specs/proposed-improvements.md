# Proposed improvements

`docs/proposed-improvements.md` records every idea for a skill, agent or feature in this plugin, and what was decided about it, so an idea that was turned down stays turned down and a shipped one is marked as shipped. Whoever proposes an idea reads it first; the maintainer's verdict sets each status.

## Context

The record is written for people. AGENTS.md tells anyone proposing a skill, agent or feature to read it first. The repo's check script, `scripts/check.py`, runs locally whenever a skill or this record changes.

## Scope

In: the record's format and statuses, its AGENTS.md rule, and the check script's checks on it.
Out: CI for this repo; checking each skill has a README section.

## Behaviour

```gherkin
Scenario Outline: Proposed improvements stay honest
  Given docs/proposed-improvements.md has a row for <idea> marked <status>
  When the repo's checks run
  Then they <result>

  Examples:
    | idea                       | status   | result                                  |
    | a skill that exists        | Done     | pass                                    |
    | a skill that doesn't exist | Done     | fail: it says done but there's no skill |
    | a skill that exists        | Rejected | fail: a rejected idea got built         |
    | anything                   | Someday  | fail: not one of the known statuses     |
```

## Design

A short intro defining each status (Proposed, Planned, Done, Skipped for now, Rejected), then one table of ideas with their status and a note saying what the idea is, plus why for Skipped for now or Rejected. A skill or agent idea's cell starts with `` `wbc:<name>` ``. The AGENTS.md rule says to read the record before proposing an idea, never to propose a Rejected one again, to add each new idea with the user's verdict as its status, and to mark an idea Done in the PR that ships it. The check script fails on an unknown status, on a Done row naming a `wbc:` skill or agent that doesn't exist, and on a Rejected row naming one that does.

Testing: the check script with rows that should pass and fail.

## Decisions

- **A table with fixed statuses, checked by the script**: Why: "never do it" only sticks if a rejected idea can't quietly come back. Not free-form notes: nothing could check them.
- **Its own spec, not part of setup's**: Why: it's the repo's own record, not something `setup` does. Not left in setup's spec, where it shipped first.
