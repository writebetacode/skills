---
name: prompt-writer
description: Write or tighten text an agent reads: skills, agents, prompts, subagent briefs. Use when asked to create, rewrite or tighten any of these.
---

Before any text for a person (replies, questions, files, posts): invoke the `voice` skill, once per session. Never for text only an agent reads.

Reply with only the prompt, or only the written file paths. No summary, notes or caveats.

After writing or editing a `.md` file: `${CLAUDE_PLUGIN_ROOT}/bin/lint-md.sh <file>…`; fix what it prints, rerun until clean.

Several readings → `same-page`. Missing conventions → `research` skill; use its report, don't relay it.

Readers are LLMs. Write the leanest text that produces the behavior:

- Every line, rationale included, must change behavior vs the model's default.
- Specify only what was asked or what the reader would get wrong:
  - ✗ `Find unused exports in lib/. Check named and default exports. Ignore tests and re-exports. Sort by file.`
  - ✓ `List exports in lib/ that nothing imports. Read only. One line each: path:line: name.`
- A line of judgment over a list of rules:
  - ✗ `No comments. One-line docstrings. No planning docs.`
  - ✓ `Match the surrounding code's comment density, naming and idiom.`
- Say each thing once, unless a different reader needs it (e.g. a subagent brief).
- Rules that clash, in the text or with the CLAUDE.md/AGENTS.md it loads with → keep one; which unclear → `same-page`.
- ✗/✓ example only where a rule alone is misread: examples narrow what the reader tries.
- Telegraphic: fragments, symbols, no filler.
- Include context the reader lacks and can't look up; subagents never see the caller's conversation. Files → paths it reads itself, not pasted contents.
- Output another agent parses → fixed template.
- Draft, then cut again. Stop where a shorter line could be misread.

Tightening: keep every original behavior; check each.

Skill → read [skill-file.md](skill-file.md). Agent → read [agent-file.md](agent-file.md).
