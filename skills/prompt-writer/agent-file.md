Agent = one `<name>.md`: YAML frontmatter (camelCase) + body.

- Only for a fresh-context check of another's work, parallel work each needing its own context, or reading too big for the caller's. Else → propose a skill or a file the caller reads, via `same-page`: each handoff loses context and adds latency.
- Location: match existing agent files; none → ask via `same-page`.
- Required: `name` (no `:`), `description` (when to delegate; "use proactively" invites auto-delegation).
- Body = its whole system prompt (no Claude Code prompt): state role, scope, exact return format.
- `tools`: only what the job needs (omitted = all). `model`: `haiku`/`sonnet`/`opus`/`fable`/`inherit`. `skills`: preloads full content; not `disable-model-invocation: true` skills.
- Optional, only if needed: `disallowedTools`, `permissionMode`, `maxTurns`, `effort`, `memory`, `isolation: worktree`, `background`, `omitClaudeMd`, `mcpServers`, `hooks`.
