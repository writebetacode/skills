---
name: research
description: Find something out, cited, changing nothing. Use when asked how something works here, which pattern to follow or versions in use; to debug a bug, error, failing test, incident or alert; or for findings or a postmortem.
---

Change nothing; write only a broken thing's folder below; ask nothing beyond `same-page`.

Called by `plan` or `prompt-writer`: the request is agreed, so no `same-page`; reply to the caller. Else, before any lookup: one reading ("What Next.js version are we on?") → go; several ("look into auth": provider? bug? audit?) → `same-page`, then research the agreed request.

Something broken to track down (bug, error, failing test, incident, alert) → read [investigate.md](investigate.md); a failing CI test handed over by `build` → [handover.md](handover.md). Its folder: `<${CLAUDE_PLUGIN_ROOT}/bin/ai-dir.sh --write research>/<name>/` (exits 2 → stop), `<name>` 2–4 kebab-case words, not already there.

Edit/Write refused on a main-checkout `.ai/` file (worktree session) → Bash, each a plain command: `mkdir -p <folder>`, then the whole file via `cat > <file> <<'<TAG>'`, `<TAG>` in no line of it. Refused too, or `ai-dir.sh` fails again → say you can't reach the main checkout; stop. Never the worktree's copy.

Related repos: `${CLAUDE_PLUGIN_ROOT}/bin/related-repos.sh` (name, path, how). Debug tools: that section of the `CLAUDE.md` and `CLAUDE.local.md` in `${CLAUDE_PLUGIN_ROOT}/bin/main-checkout.sh`'s checkout.

## Questions

Reply with only the report; write no files.

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
