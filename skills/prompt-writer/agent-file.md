Agent = one `<name>.md`: YAML frontmatter (camelCase) + body.

- Location: match existing agent files; none → ask via `same-page`.
- Required: `name` (no `:`), `description` (when to delegate; "use proactively" invites auto-delegation).
- Body = its whole system prompt (no Claude Code prompt): state role, scope, exact return format.
- `tools`: only what the job needs (omitted = all). `model`: `haiku`/`sonnet`/`opus`/`fable`/`inherit`. `skills`: preloads full content; not `disable-model-invocation: true` skills.
- Optional, only if needed: `disallowedTools`, `permissionMode`, `maxTurns`, `effort`, `memory`, `isolation: worktree`, `background`, `omitClaudeMd`, `mcpServers`, `hooks`.
