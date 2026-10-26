Skill = `<name>/SKILL.md`: YAML frontmatter + body.

- `description` (always in context; drives triggering): use case first; one trigger per distinct case; ≤1,536 chars; when-to-use only here.
- Invokers: default Claude + user. Claude/skills only → `user-invocable: false`, description ending "Use only when another skill calls for it." User only → `disable-model-invocation: true` (no skill or agent can call or preload it).
- Body: inline what every path needs; branch-only material → sibling files behind a when-to-read pointer, named unlike `SKILL.md` ignoring case.
- Mechanical steps and hard preconditions (lookups, parsing, a check a later step needs) → a script beside it that prints what to do when it fails; the body says only when to run it.
- Optional, only if needed: `model`/`effort` (rest of turn; with `context: fork` + `agent`, the forked subagent's), `allowed-tools`/`disallowed-tools`, `paths` (glob auto-load), `arguments`, substitutions `$ARGUMENTS`, `${CLAUDE_SKILL_DIR}`, `${CLAUDE_EFFORT}`. Skip `argument-hint`.
