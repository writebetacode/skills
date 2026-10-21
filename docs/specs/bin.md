# Shared scripts

The plugin's `bin/` folder holds the scripts more than one skill runs, so each shared answer has one source: a repo's related repos, host, default branch and spec folders, and whether Markdown lints clean. It's for the skills that run them and whoever maintains the skills.

## Why

Skills working out the same answer their own way drift apart: one finds a repo's specs, another starts a second folder beside them. And outside this repo, whose lint hook runs only here, nothing linted the Markdown the skills wrote.

## What

Each script prints one answer for any skill that asks. `scripts/check.py` checks, before each commit here, that skills run them the right way.

## Behaviour

- `related-repos.sh [path]` prints the Related repos entries in the main checkout's `CLAUDE.md` and `CLAUDE.local.md`, tab-separated: name, absolute path, how they relate. Outside a repo, it reads the folder's own files.
- An entry with no path gets the folder named for the repo beside the main checkout; missing paths still print.
- `host.sh` prints `github` or `gitlab` for origin. When it can't tell, the skill asks you, or `daily` marks the repo not checked.
- `default-branch.sh [path]` prints origin's default branch, read fresh from origin.
- `specs-dir.sh [path]` prints the repo's spec folders relative to its root, most specs first: each outermost folder named `specs` holding tracked Markdown, like `docs/superpowers/specs` or `openspec/specs`. With none, it prints `docs/specs`; outside a repo, it fails.
- `plan` puts a new spec in the first folder printed; `plan`, `build` and `review` find specs in all of them.
- `lint-md.sh <file>…` fixes what it can in just those files, then prints each problem left as `<file>:<line> <rule>`.
- `plan`, `research`, `review`, `release`, `prompt-writer` and `setup` lint the Markdown they write in a repo; `build` lints only plan files and specs.
- When a script fails, the skill tells you why in the script's words.
- `check.py` fails, naming the file, on a shared script that's missing, not executable or run by nothing; a skill running another skill's script, writing `.ai/` files without `lint-md.sh`, or naming `docs/specs`; and a template markdownlint rejects, placeholders like `<name>` aside. Without `npx`, it skips templates and says so.

## Sketch

```
$ bin/specs-dir.sh ~/code/shop
docs/superpowers/specs
docs/specs
```

## Decisions

- **Shared scripts in the plugin's `bin/`**: Why: each answer has one source, and no skill reaches into another's folder. Not a copy per skill: copies drift.
- **Spec folders are found, most specs first, from tracked Markdown only**: Why: repos keep specs in many places, and one script means every skill agrees. The folder with the most specs is the one the team uses, and a plan's own `specs/`, under the gitignored `.ai/`, isn't the repo's.
- **Skills lint the Markdown they write, never your own files**, like your notes file and `~/.claude/CLAUDE.md`. Why: fixing yours would rewrite your lines. Not a plugin hook: it would run on every edit in every repo, rewriting your Markdown to rules you never picked.
- **A repo's own markdownlint setup for files it commits, the plugin's rules for the rest**: Why: committed files face the repo's CI, while `.ai/` files and `CLAUDE.local.md` hold formats the skills read back. Markdownlint's default 80-character limit would hard-wrap plan files, and a required title heading would break `status.md`.

## Out of scope

- Finding a folder's main checkout and `.ai/` folder (the .ai folder spec), cleaning up merged branches (the pr spec), and `setup` editing Related repos lines (the setup spec).
- Scripts only one skill runs, which stay in its folder.
