# Shared scripts

Scripts that more than one skill runs live in the plugin's `bin/` folder, so no skill reaches into another skill's folder and each answer has one source. It's for the skills that run them and for whoever maintains the skills.

## Context

Claude Code fills in `${CLAUDE_PLUGIN_ROOT}` in a plugin skill's `SKILL.md` but not in the sibling files a skill reads later; it prints the skill's base directory when the skill loads. `scripts/check.py` checks the skills before each commit: links, word budgets, executable scripts, files nothing points at.

## Scope

In: the `bin/` folder and how skills and scripts run its scripts; `related-repos.sh`; `host.sh`; `default-branch.sh`; `check.py`'s checks of `bin/`; the AGENTS.md rules on skill scripts and on where a mechanical rule lives.
Out: what `main-checkout.sh` and `ai-dir.sh` do (the ai-folder spec) and what `prune-merged.sh` does (the pr spec); scripts only one skill runs, which stay in that skill's folder; `setup`'s reads of Related repos, which edit the raw lines (the setup spec); a skill or script running a script from another skill's folder.

## Behaviour

```gherkin
Scenario: A broken script path fails the check
  Given a skill runs ${CLAUDE_PLUGIN_ROOT}/bin/related-repo.sh, a name that doesn't exist
  When you run scripts/check.py
  Then it fails, naming the skill and the missing script

Scenario: Related repos have one parser
  Given shop's CLAUDE.local.md lists "- acme/web (../web): calls /api/cart/*" under Related repos
  When plan, research, review or daily asks for shop's related repos
  Then each gets acme/web with web's absolute path and how it relates, from related-repos.sh
```

## Design

`bin/` at the plugin's root holds `main-checkout.sh`, `ai-dir.sh`, `related-repos.sh`, `prune-merged.sh`, `host.sh` and `default-branch.sh`. A skill's `SKILL.md` runs them as `${CLAUDE_PLUGIN_ROOT}/bin/<script>`, its sibling files as `<this skill's base directory>/../../bin/<script>`, a skill's own script as `$(dirname "$0")/../../bin/<script>`, and one `bin/` script another as `$(dirname "$0")/<script>`. Each script's messages say why it failed, and callers report them, with two exceptions: `host.sh` failing → ask the user which host (`daily` marks that repo not checked instead), and `ai-dir.sh`'s exit 1 (the ai-folder spec).

- `related-repos.sh [path]` prints the `## Related repos` entries of a folder's main checkout (or of the folder itself outside a repo), from its `CLAUDE.md` and `CLAUDE.local.md`, one per line, tab-separated: the name, the absolute path resolved from that checkout, and how they relate. An entry with no `(path)` gets the sibling folder named for the name's last part; paths print whether or not they exist, for the caller to check. No entries → nothing, exit 0; where `main-checkout.sh` exits 2, it exits 2. `plan`, `research`, `review` and `daily`'s `active-repos.sh` read Related repos only through it.
- `host.sh` prints `github` or `gitlab` for `origin`, asking `gh` and `glab` when the URL doesn't say; it exits 1 when it can't tell.
- `default-branch.sh [path]` prints `origin`'s default branch name, refreshed from `origin`.

`check.py` resolves every path form above, failing on a missing script or one that isn't executable, on a `bin/` script nothing runs, and on any skill file or script that runs a script from another skill's folder. That last check lands once `setup` stops running `daily`'s `sessions.sh`. AGENTS.md's rule on skill scripts names `bin/`, and its rule on a mechanical rule every skill needs points to a `bin/` script.

Testing: the repo's check script and markdownlint; `related-repos.sh` on a checkout whose files list a relative, a `~`, an absolute and a missing path.

## Decisions

- **Shared scripts in the plugin's `bin/`**: Why: no skill reaches into another skill's folder, and each answer still has one source. Not a copy per skill: copies drift. Not living in whichever skill used it first: every other caller then depends on that skill's folder.
- **Sibling files reach `bin/` through the skill's base directory**: Why: Claude Code substitutes only in `SKILL.md`, and the base directory is printed when a skill loads. Not repeating the full path in each `SKILL.md` for its siblings to copy: one more line per skill that says nothing new.
