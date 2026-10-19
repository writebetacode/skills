---
name: setup
description: Set up the wbc skills on this machine: check gh, glab, acli, jq and npx, link related repos and list debug tools in each repo's CLAUDE.local.md, and choose daily's sources. Run it again to add repos.
disable-model-invocation: true
---

Walk the user through each step. Ask via `same-page`; step 6's changes are shown in full outside it. Write nothing before step 6's confirm.

Each repo's files live in its main checkout: `${CLAUDE_PLUGIN_ROOT}/bin/main-checkout.sh <path>` (fails → skip that path, saying why).

1. Repos: the repo you're in, if any, plus the paths the user names, or each git repo up to two levels under a folder they name (`find <folder> -maxdepth 3 -name .git -type d`: skips worktrees and submodules). Re-run → also each repo already under `## Related repos` in those repos' `CLAUDE.md` or `CLAUDE.local.md`.
2. Tools: in each repo, `${CLAUDE_PLUGIN_ROOT}/bin/host.sh` (fails → ask) and the host from `git remote get-url origin` (an SSH alias → `ssh -G <alias> | awk '/^hostname /{print $2}'`); ask whether they use Jira. Per host, installed (`command -v`) and logged in; `git --version` 2.38 or later. Never install or log in yourself; tell them to run the login with `!`.

   | Tool | Logged in | Login | Install |
   | --- | --- | --- | --- |
   | `git` | | | <https://git-scm.com/downloads> |
   | `gh` | `gh auth status --hostname <host>` | `gh auth login --hostname <host> --web` | <https://cli.github.com> |
   | `glab` | `glab auth status --hostname <host>` | `glab auth login --hostname <host> --web` | <https://gitlab.com/gitlab-org/cli> |
   | `acli` | `acli jira auth status` | `acli jira auth login --web` | <https://developer.atlassian.com/cloud/acli/> |
   | `jq` | | | <https://jqlang.org/download/> |
   | `npx` | | | <https://nodejs.org/en/download> |

3. Links, from evidence in the code only, never names alone: package dependencies between them; one calling another's API (routes it serves vs clients and base URLs); shared schemas or message topics; compose services; submodules. Each link → a line in both repos: the other repo's name (its `origin`'s owner/repo, else its folder's name), its path relative to the main checkout whose file it's in, how they relate in ≤12 words:
   - ✓ `- acme/web (../web): imports @acme/cart; calls /api/cart/*`
4. Debug tools, only for repos with no `## Debug tools` in `CLAUDE.md` or `CLAUDE.local.md`: propose lines from what the repo shows (cluster manifests → logs, error-tracker config, compose → logs, a read-only database by its variable or secret name, never a value) and the connected tools in this session; the user confirms or fills them in.
   - ✓ ``- Logs: `kubectl logs -n shop deploy/api --since=24h` ``
5. Daily's sources, for `## Daily` in `~/.claude/CLAUDE.md`: offer each host logged in at step 2 (`GitHub`, `GitLab: <host>`, `Jira`) and each connected tool in this session that reads chat, docs or tickets (`Slack: <tool>, <channels or DMs>`); ask for a notes file (`Notes: <path, {date} for the day>, under <heading>`), offering the current `Notes:` line. One `Notes:` line only: a different answer replaces it. A `## Daily` there → add only source lines it lacks.
6. Show every change, per repo and for `~/.claude/CLAUDE.md`, then ask to confirm; write only once they do, per [write.md](write.md).
7. Reply: the tool checklist, with each fix; per file (each repo's, `~/.claude/CLAUDE.md`), the lines added; anything not written, and why; what's left for the user.
