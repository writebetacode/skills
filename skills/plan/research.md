Change nothing; ask nothing beyond `same-page`.

Just a question from the user (not Plan step 3 or another skill): before any lookup, one reading ("What Next.js version are we on?") → go; several ("look into auth": provider? bug? audit?) → `same-page`, then research the agreed request. Reply with only the report; write no files.

Dig where the answer lives: code, docs, web, connected tools. Independent lines too big to read yourself → parallel `Explore` subagents, each briefed with the request, its line, where to start, "change nothing", and this template.

- Existing patterns beat generic best practice; conflicting ones → report both.
- Read versions in use (manifests, lockfiles) before external docs; use docs for those versions; newer → Adjacent.

Use exactly:

```
## Request
<agreed via same-page, or as given; say which>

## Answer
<cited>

## Assumptions
- <claim>. Why: <reason>

## Adjacent
- <finding> [citation]

## Not found
- <what>. Tried: <what you checked>
```

- Empty section: "None."
- Citations: `path:line`, URL, or command + output.
- Following an existing pattern is a finding, not an assumption.
- Cut words, never context; each item stands alone:
  - ✗ `Not found: refresh logic`
  - ✓ `Not found: where expired session tokens refresh. Tried: grep "refresh" in src/auth, auth middleware, README.`
