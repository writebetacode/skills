# Shared scripts

Scripts that more than one skill runs live in the plugin's `bin/` folder, so no skill reaches into another skill's folder and each answer has one source. It's for the skills that run them and for whoever maintains the skills.

## Context

Claude Code fills in `${CLAUDE_PLUGIN_ROOT}` in a plugin skill's `SKILL.md` but not in the sibling files a skill reads later; it prints the skill's base directory when the skill loads. `scripts/check.py` checks the skills before each commit: links, word budgets, executable scripts, files nothing points at.

## Scope

In: the `bin/` folder and how skills and scripts run its scripts; `related-repos.sh`; `host.sh`; `default-branch.sh`; `lint-md.sh` and which skills run it; `check.py`'s checks of `bin/` and of the skills' Markdown templates; the AGENTS.md rules on skill scripts, on where a mechanical rule lives and on linting the Markdown skills write.
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

Scenario: Markdown a repo commits follows the repo's rules
  Given shop's .markdownlint.jsonc limits lines to 80 characters
  When build writes a spec with a 120-character line into shop's docs/specs/
  Then lint-md.sh reports that line, and build wraps it before committing

Scenario: Markdown git ignores follows the plugin's rules
  Given shop's .markdownlint.jsonc limits lines to 80 characters
  When plan writes a status.md with a 120-character line and no blank line under a heading into shop's .ai/plan/
  Then lint-md.sh adds the blank line and says nothing about the line's length

Scenario: A template that fails markdownlint fails the check
  Given a skill's template has a heading with no blank line under it
  When you run scripts/check.py
  Then it fails, naming the skill file, the line and the rule
```

## Design

`bin/` at the plugin's root holds `main-checkout.sh`, `ai-dir.sh`, `related-repos.sh`, `prune-merged.sh`, `host.sh`, `default-branch.sh` and `lint-md.sh`. A skill's `SKILL.md` runs them as `${CLAUDE_PLUGIN_ROOT}/bin/<script>`, its sibling files as `<this skill's base directory>/../../bin/<script>`, a skill's own script as `$(dirname "$0")/../../bin/<script>`, and one `bin/` script another as `$(dirname "$0")/<script>`. Each script's messages say why it failed, and callers report them, with two exceptions: `host.sh` failing → ask the user which host (`daily` marks that repo not checked instead), and `ai-dir.sh`'s exit 1 (the ai-folder spec).

- `related-repos.sh [path]` prints the `## Related repos` entries of a folder's main checkout (or of the folder itself outside a repo), from its `CLAUDE.md` and `CLAUDE.local.md`, one per line, tab-separated: the name, the absolute path resolved from that checkout, and how they relate. An entry with no `(path)` gets the sibling folder named for the name's last part; paths print whether or not they exist, for the caller to check. No entries → nothing, exit 0; where `main-checkout.sh` exits 2, it exits 2. `plan`, `research`, `review` and `daily`'s `active-repos.sh` read Related repos only through it.
- `host.sh` prints `github` or `gitlab` for `origin`, asking `gh` and `glab` when the URL doesn't say; it exits 1 when it can't tell.
- `default-branch.sh [path]` prints `origin`'s default branch name, refreshed from `origin`.
- `lint-md.sh <file>…` fixes Markdown files in place with markdownlint-cli2, at the one version it pins, then prints what's left to fix by hand, a line per error with the file's full path, and exits 1. A file its repo would commit, in a repo with its own markdownlint setup (a config file in the file's folder or any folder above it up to the repo's top, or markdownlint in its `package.json`), follows that setup, the way the repo's own linter would. Everything else follows the plugin's `.markdownlint-cli2.jsonc`, which is also this repo's: files git ignores (`.ai/`, `CLAUDE.local.md`), files outside a repo, and repos with no setup. Those go through stdin, since markdownlint otherwise layers any config near the file on top of the one it's given. `--no-globs` keeps a repo config's `globs` from linting the whole repo.

`plan`, `research`, `review`, `release`, `prompt-writer` and `setup` (for `CLAUDE.local.md`) run `lint-md.sh` on each Markdown file they write or edit, then fix what it prints. `build` runs it only in the plan folder and `docs/specs/`, so a repo's other docs stay with that repo's linter. `daily`'s notes file and `~/.claude/CLAUDE.md` aren't linted, because `--fix` would rewrite the user's own lines. This repo's markdownlint hook runs it on the Markdown Claude changes here.

`check.py` resolves every path form above, failing on a missing script or one that isn't executable, on a `bin/` script nothing runs, and on any skill file or script that runs a script from another skill's folder. It also lints every template in a skill file (a code fence with no language that holds a heading) with the plugin's rules, minus the inline HTML rule, since placeholders like `<name>` look like tags, and it fails a skill that writes `.ai/` files without running `lint-md.sh`. With no `npx` it skips the templates and says so. AGENTS.md's rule on skill scripts names `bin/`, its rule on a mechanical rule every skill needs points to a `bin/` script, and its rule on written Markdown names `lint-md.sh`.

Testing: the repo's check script and markdownlint; `related-repos.sh` on a checkout whose files list a relative, a `~`, an absolute and a missing path; `lint-md.sh` on a committed and an ignored file in a repo with its own config, in a repo with none, and outside a repo.

## Decisions

- **Shared scripts in the plugin's `bin/`**: Why: no skill reaches into another skill's folder, and each answer still has one source. Not a copy per skill: copies drift. Not living in whichever skill used it first: every other caller then depends on that skill's folder.
- **Skills lint the Markdown they write**: Why: outside this repo, whose hook runs only here, nothing linted the specs, changelogs and plan files they wrote. Not a plugin hook: it would run on every edit in every repo and rewrite the user's own Markdown to rules they never picked.
- **A repo's rules for files it commits, the plugin's for the rest**: Why: committed files face the repo's CI, while `.ai/` files and `CLAUDE.local.md` hold formats the skills read back. Not always the plugin's rules: committed specs would fail the repo's linter. Not always the repo's: markdownlint's default 80-character limit would hard-wrap plan files, and a required title heading would break `status.md`.
- **Sibling files reach `bin/` through the skill's base directory**: Why: Claude Code substitutes only in `SKILL.md`, and the base directory is printed when a skill loads. Not repeating the full path in each `SKILL.md` for its siblings to copy: one more line per skill that says nothing new.
