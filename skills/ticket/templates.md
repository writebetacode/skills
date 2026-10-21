Ticket titles and bodies, one template per kind; `plan`'s ticket files use them too.

Content, in titles, bodies, edits and comments: what was seen or is wanted, and why it matters to users. Never how: no causes, code, files or fixes, even when the request names them.

- ✗ `Add a null check in cartTotal()` ✓ `An empty cart's checkout shows 0.00`

Title: GitHub/GitLab `<type>: <Summary>` (`fix`, `feat`, `chore`…); Jira: summary only, type as `--type` (a type the project defines). A plan's ticket file: `# <title>`, then the body.

Team style: filing, or writing a plan's tickets when its `ticket:` names a tracker → read that project's 3 latest tickets of that kind (`ticket` skill: `list`, or Jira's `search`, then `view`). They share a shape (headings, sections, how ACs are written) → use theirs, holding what these hold; else these. Jira: no checkboxes.

Feature (`feat`):

```
## Description

<≤3 sentences: what it adds, for whom>

## Why

<the need it meets>

## Acceptance criteria

- [ ] <observable outcome: it's done when…>
```

Bug (`fix`):

```
## Description

<≤3 sentences: what goes wrong, for whom>

## Steps to reproduce

- <step>

## Expected

<what should happen>

## Actual

<what happens>

## Acceptance criteria

- [ ] <observable outcome: it's done when…>
```

Task (`chore`, `refactor`, `docs`…): Feature's, its Description saying what changes.
