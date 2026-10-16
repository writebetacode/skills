Writes, once the user confirms (SKILL.md step 6). A write that fails stops here: the reply names what was written and what wasn't.

1. Before the first write, `git -C <repo> check-ignore -q CLAUDE.local.md` fails anywhere → ask once, then append `CLAUDE.local.md` on its own line to `git config --global --includes --path core.excludesFile`; unset → give them `! mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/git" && printf '\nCLAUDE.local.md\n' >> "${XDG_CONFIG_HOME:-$HOME/.config}/git/ignore"` (Claude Code protects it). Still failing → name those repos.
2. Per repo, its main checkout's `CLAUDE.local.md`:
   - Missing → create it; the repo has `AGENTS.md` and no `CLAUDE.md` → first line `@AGENTS.md` (else Claude stops reading `AGENTS.md`).
   - Section missing → append it. A repo already listed by name, in this file or the repo's `CLAUDE.md` → skip it. A listed path that no longer resolves from the main checkout → the same-named repo's path among this run's repos, in every `CLAUDE.local.md` you read (no match → list it as left; stale in `CLAUDE.md` → tell the user). Else add its line. Never remove or reword other lines.
3. Then `~/.claude/CLAUDE.md`: the Daily section as agreed. Refused → show the section for them to paste.

Edit/Write refused on a main checkout's `CLAUDE.local.md` (worktree session) → Bash, a plain command: the whole file via `cat > <file> <<'<TAG>'`, `<TAG>` in no line of it. Refused too → say you can't reach the main checkout; stop. Never the worktree's copy.
