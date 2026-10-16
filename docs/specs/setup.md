# Setup

`setup` walks you through everything the other skills read from your machine (the command-line tools, which of your repos depend on each other, how to reach each repo's logs and errors, and `daily`'s sources), so `plan`, `review` and `daily` don't miss what they can't find on their own. It also learns from your recent sessions: corrections you keep making become rules for that repo, and times a wbc skill went wrong become anonymous issue drafts for the plugin, filed only when you say so.

## Context

`plan` and `review` read `## Related repos`, and `plan`'s investigations `## Debug tools`, from the `CLAUDE.md` and `CLAUDE.local.md` of a repo's main checkout; `daily` reads a `## Daily` section from your global `~/.claude/CLAUDE.md`. The skills call `gh`, `glab`, `acli` and `jq`.

Claude Code loads `CLAUDE.local.md` next to `CLAUDE.md`, and from parent folders too, but doesn't ignore it in git for you. It also counts as a `CLAUDE.md`, so adding one to a repo that only has `AGENTS.md` stops Claude reading `AGENTS.md`, unless the new file imports it. Claude Code puts its own worktrees inside the checkout a session started from, usually the main one, so they load that checkout's `CLAUDE.local.md`; a worktree elsewhere doesn't.

`daily`'s `sessions.sh` prints each Claude Code session on a local day, without a session id: its folder, branch, title, PRs, up to 40 of your prompts (slash commands included, each clipped to 300 characters) and Claude's last reply, skipping subagents and sessions in temp folders. It doesn't show the skills Claude started on its own. A shared script maps any folder to its repo's main checkout, including Claude Code worktrees removed since. `ticket` files and searches GitHub issues; filing on the plugin's repo, writebetacode/skills, needs `gh` logged in to github.com.

## Scope

In: the CLI checks; related repos, with paths every reader resolves from the main checkout; debug tools; `daily`'s sources; learning from your sessions of the past 14 days; a `Skills:` line in `sessions.sh`; the README's `setup` section.
Out: installing or logging in to CLIs for you; editing a repo's committed `CLAUDE.md`, `AGENTS.md` or `.gitignore`; filing an issue without your OK.

## Behaviour

```gherkin
Scenario: Only you start it
  Given a session where nobody typed /wbc:setup
  Then Claude never runs setup on its own

Scenario: CLI checks
  Given gh is installed but logged out, and acli isn't installed
  When you run setup
  Then it says gh needs "gh auth login", which you can run with "!"
  And it gives the install link for acli
  And it runs no login or install itself

Scenario: Link repos found in a folder
  Given ~/code/acme holds web, api and infra, and web calls api's cart endpoints
  When you point setup at ~/code/acme and confirm the links it shows
  Then web's CLAUDE.local.md lists acme/api with its path and how web uses it
  And api's CLAUDE.local.md lists acme/web the same way
  And infra gets no Related repos entry, because nothing ties it to the others

Scenario: Name repos one by one
  Given you're in web and name ../api instead of a folder
  When you confirm the links
  Then only web and api are scanned and linked

Scenario: Writes go to the main checkout
  Given you run setup from a worktree of web
  When it writes web's lines
  Then they go into the CLAUDE.local.md of web's main checkout

Scenario: A Claude Code worktree session writes with shell commands
  Given you run setup in a session Claude Code isolates in ~/code/web/.claude/worktrees/docs
  When Claude Code refuses to write web's CLAUDE.local.md
  Then setup writes the whole file with shell commands, never the worktree's copy

Scenario: A sandbox that blocks the main checkout stops setup
  Given a session Claude Code isolates in a worktree of web, whose sandbox won't let shell commands write into ~/code/web
  When setup writes web's CLAUDE.local.md after you confirm
  Then it says it can't reach the main checkout and stops, writing nothing in the worktree
  And its reply lists the files it had already written and the ones it didn't

Scenario: Nothing is written before you confirm
  Given setup has worked out its changes
  When you haven't confirmed them yet
  Then no file has changed

Scenario: Run it again to add a repo
  Given web and api are already linked, and you added a line of your own to web's Related repos
  When you run setup again and add ~/code/acme/billing, which api calls
  Then api and billing gain entries for each other
  And every existing line, yours included, stays exactly as it was

Scenario: A linked repo that moved
  Given web's CLAUDE.local.md lists acme/api at ../api, api's lists acme/web at ../web, and api now lives at ~/code/acme/services/api
  When you run setup again with api's new path
  Then only that line's path changes in web's CLAUDE.local.md, to ../services/api
  And only web's line changes in api's, to ../../web
  And if web's committed CLAUDE.md lists api at its old path, setup tells you instead of editing it

Scenario: A repo that only has AGENTS.md
  Given api has AGENTS.md and no CLAUDE.md or CLAUDE.local.md
  When setup creates api's CLAUDE.local.md
  Then the file imports AGENTS.md first, so Claude still reads it

Scenario: Keep CLAUDE.local.md out of git
  Given git doesn't ignore CLAUDE.local.md in web
  When setup is about to write it
  Then it asks once to add CLAUDE.local.md to your global git excludes file
  And if you say no, it lists the repos where the file will show up as untracked

Scenario: Debug tools
  Given api has Kubernetes manifests and a Sentry config, and no Debug tools section
  When setup runs
  Then it proposes Debug tools lines for logs and errors and asks you to confirm or fill them in
  And a repo that already has a Debug tools section keeps it as is

Scenario: Daily's sources
  Given gh and acli are logged in and a Slack connector is connected
  When you run /wbc:setup and choose GitHub, Jira, Slack and a notes file
  Then ~/.claude/CLAUDE.md gets a Daily section listing them, with your notes file on its one Notes line
  And an old Recap section's notes file was offered as the default answer, and the Recap section goes once you confirm
  And choosing a different notes file later replaces the one Notes line

Scenario: Repeated corrections become rules
  Given on three different days in the past 14, one of them in a worktree of shop, you told Claude to use pnpm, not npm
  When you run /wbc:setup with shop among its repos
  Then it proposes "- Use pnpm, not npm" under Learned in the CLAUDE.local.md of shop's main checkout
  And it writes nothing until you confirm

Scenario: A one-off correction is left alone
  Given you corrected something on only one day
  When you run /wbc:setup
  Then it proposes no rule for it

Scenario: A rule you already have isn't proposed again
  Given shop's CLAUDE.local.md already says "- Use pnpm, not npm"
  And the sessions that taught it are still in the past 14 days
  When you run /wbc:setup again
  Then it doesn't propose that rule

Scenario: A skill misfire becomes an anonymous issue draft
  Given in a session in acme/billing, which isn't among setup's repos, build committed before you said go and you corrected it
  When you run /wbc:setup
  Then it drafts an issue for writebetacode/skills describing the same misfire in a made-up sample repo
  And the draft holds no repo names, paths, people, code or company details
  And it files the issue on writebetacode/skills, linked to any related issue, only once you say so

Scenario: A misfire already reported isn't drafted again
  Given writebetacode/skills already has an open issue about that misfire
  When you run /wbc:setup
  Then it drafts nothing for it and says it's already reported

Scenario: No gh login for github.com
  Given setup has an issue draft and gh isn't logged in to github.com
  When it drafts the issue
  Then the draft is marked as not checked against existing issues
  And when you OK it, it shows the draft and the link to file it by hand
```

## Design

`setup` lives in `skills/setup/`, runs only when you type it, and walks you through these steps, asking one thing at a time:

1. Which repos: specific paths, or a folder whose git repos (up to two levels down) it scans. The repo you're in is always included. Each repo's lines go to the main checkout the shared script finds; in a bare repo that's the worktree you named, and a folder with no checkout (a bare git folder, or the bare layout's top folder) is skipped, saying why. On a re-run it also re-reads the repos already listed in those repos' Related repos sections.
2. Which hosts and trackers you use: the hosts behind each repo's `origin`, and whether you use Jira. For each, it checks the CLI is installed and logged in (`gh`, `glab` for that host, `acli` for Jira), plus `jq`, and reports a short checklist with the command to fix each gap.
3. How the repos relate, from evidence in the code only: package dependencies between them, one calling another's API, shared schemas or message topics, compose files, submodules. More than a few repos are scanned by parallel read-only subagents, one per repo. Each link becomes a line in both repos: the other repo's name (its `origin`'s owner and repo, like `acme/api`, else its folder's name), its path relative to this repo's main checkout, and how they relate in a few words.
4. Debug tools, for repos without a section: lines proposed from what the repo shows (cluster manifests, error-tracker config, compose files, a read-only database named by its variable or secret, never a value) and the connected tools in the session, for you to confirm or fill in.
5. `daily`'s sources: the hosts logged in at step 2 and the connected tools that read chat, docs or tickets, plus a notes file, offering the current `Notes:` line, else an old `## Recap` section's file, as the default answer. An existing `## Daily` section only gains source lines it lacks, and keeps one `Notes:` line, which your answer replaces; an old `## Recap` section goes once you OK it.
6. Learning from sessions (below), in a file beside the skill.
7. It shows every change, per repo and for `~/.claude/CLAUDE.md`, and writes nothing until you confirm. Before the first write, if git doesn't ignore `CLAUDE.local.md`, it offers to add it to your global git excludes file, or gives you the command when you haven't set one. Then it creates or updates each repo's main-checkout `CLAUDE.local.md`. A repo already listed by name, in that file or the repo's `CLAUDE.md`, is skipped. A listed path that no longer resolves from the file's main checkout is fixed in `CLAUDE.local.md`, in every repo setup reads; a stale line in `CLAUDE.md` is reported to you. No other line changes or goes. A write it can't make stops it there, and the reply says what it wrote and what it didn't. A new file in a repo that has `AGENTS.md` and no `CLAUDE.md` starts with an import of `AGENTS.md`.
8. It replies with the checklist, each file it wrote and what it added, and anything left for you.

**In a worktree session.** In a session Claude Code isolates in a worktree, every command for the session's own repo (its `origin`, the ignore check) runs in the worktree, which shares the repo's remotes and excludes, since Claude Code refuses git pointed at the main checkout. The shared script maps folders by the paths it's given, so it runs from the worktree too. Writes to that repo's `CLAUDE.local.md` follow the ai-folder spec's line for a refused write: refused → plain shell commands write the file's whole text, expanding nothing in it, so a `$VAR` in a Debug tools line stays a name, never a value.

**Learning from sessions.** It runs `sessions.sh` for each of the past 14 days. A correction is a prompt telling Claude it did something wrong or should do it differently ("no, use pnpm", "don't mock the database"). When `sessions.sh` can't run (no `jq`, no sessions folder), learning is skipped and the reply says why; the other changes are still shown and written. For repo rules, it maps each session's folder to its main checkout with the shared script, skipping folders it can't map; for each repo from step 1, a correction of how Claude works in that repo counts when you made it on at least two different days; one already covered by a line in that repo's `CLAUDE.md`, `AGENTS.md` or `CLAUDE.local.md` is skipped. Each becomes one proposed line under a `## Learned` section in the repo's main-checkout `CLAUDE.local.md`, shown and written with the other changes.

`sessions.sh` gains a `Skills:` line listing the skills each session ran, from Claude's skill calls, so a skill Claude started on its own can be named too. Across every session in those 14 days, mapped or not, a correction of a wbc skill's own behaviour (right after a `/wbc:` command or a wbc skill on its `Skills:` line, an interrupted request, "no, that's wrong") becomes an issue draft for writebetacode/skills, never a Learned line: what the skill did against what it should have done, retold in an invented sample repo with no names, paths, people, code or company details. A misfire with an open issue about it already on writebetacode/skills (searched through `ticket`, naming that repo) is skipped and named. Each draft is written in `ticket`'s title and body format, shown in full, and handed to `ticket` only when you say so; `ticket` files that text exactly as shown, adding only the link lines its search finds. With `gh` not logged in to github.com, drafts are still made, each marked as not checked against existing issues, and an OK'd draft is shown with the link to file it by hand.

The skill's description and README section mention learning from sessions.

Testing: the repo's check script (budgets and links) and markdownlint; running it against a scratch folder of repos; and against a sessions folder with planted repeated and one-off corrections and a skill misfire, checking that the draft holds no names or paths.

## Decisions

- **Links go in each repo's `CLAUDE.local.md`, both ways**: Why: paths differ per machine and shouldn't be committed; both repos need to know about each other for `plan` and `review` to look across. Not the committed `CLAUDE.md`: it would land in every teammate's checkout with your paths.
- **Every write goes to the main checkout's `CLAUDE.local.md`**: Why: one place per repo, and Claude Code's own worktrees, when started from the main checkout, sit inside it and load it. Not each worktree's: lines would scatter and vanish with the worktree.
- **Debug tools and Learned lines load where the main checkout's file does**: Why: Claude Code's own worktrees started from the main checkout sit inside it and load it, and `plan`'s investigations read Debug tools from the main checkout wherever they run. Not copying lines into other worktrees: they'd go stale and vanish with them, so Learned lines don't reach sessions in a worktree outside the main checkout.
- **Databases by variable or secret name, never a value**: Why: `CLAUDE.local.md` is plain text on disk that every session loads. Not connection strings or passwords, even local ones.
- **`~/.claude/CLAUDE.md` is written once, after you confirm**: Why: that's where `daily` reads its sources, and Claude Code asks before each write under `~/.claude/`, so this is one more yes in a run only you start. Refused → setup shows the section for you to paste. Not a file elsewhere: Claude Code loads only that one for every session.
- **Ignore it through your global git excludes file, after asking**: Why: one change covers every repo and nothing gets committed. Not each repo's `.gitignore`: a committed change in repos setup only reads. Not `.git/info/exclude`: Claude Code protects `.git/`.
- **No excludes file set → you get the command**: Why: Claude Code protects git's default location, `~/.config/git/`, so setup's own write there would be refused. Not writing it for you.
- **Import `AGENTS.md` in a new `CLAUDE.local.md`**: Why: otherwise the new file silently stops Claude reading the repo's `AGENTS.md`. Not changing the global setting: it would change behaviour in every repo, not just the ones setup touched.
- **Links come only from evidence in the code, and you confirm them**: Why: a wrong link sends `review` and `plan` into repos that don't matter. Not guessing from names.
- **Add, never remove, in `CLAUDE.local.md`**: Why: the sections may hold lines you wrote. Not regenerating a section: it would throw your lines away.
- **An old `## Recap` section goes, with your OK**: Why: `daily`'s `Notes:` line replaces it, and two places for one setting would drift. Not keeping both.
- **Related repos paths are relative to the main checkout**: Why: the file lives there, and a Claude Code worktree sits deeper inside it, where a relative path would point somewhere else. Not paths relative to wherever a skill runs.
- **Only you start it**: Why: it writes into many repos and your git config. Not letting Claude start it.
- **Learning lives in setup, writing `CLAUDE.local.md`**: Why: setup already writes that file on one confirm, and you re-run it. Not a new skill: one more description in every session's context. Not the committed `CLAUDE.md`: these are your corrections.
- **14 days, at least two different days**: Why: long enough for a habit to show; a single correction is noise; the session script lists sessions per day without ids, so days are what it can count. Not every session ever: old habits go stale.
- **Rules you already have, and misfires already reported, are skipped**: Why: re-runs would otherwise repeat them. Not relying on "add, never remove" to catch duplicates.
- **A proposal you decline can come back**: Why: setup keeps no record of its own, and the sessions behind it age out of the 14 days. Not a file of declined proposals: one more file per repo to keep for something you can decline again.
- **`sessions.sh` names the skills a session ran**: Why: a misfire has to be pinned on a skill, and many run without you typing them (`branch`, `commit`, `same-page`). Not only sessions with a typed `/wbc:` command: those misfires would be missed.
- **A bare repo's lines go in the worktree you name**: Why: it has no main checkout, and lines must never land in a git folder, as with `.ai/`. Not the bare layout's top folder: no session runs there.
- **Only an open issue stops a draft**: Why: an open issue is already being tracked, while a closed one may have come back, and a merely related one isn't the same problem; `ticket` links them to the new issue. Not skipping on any match.
- **Learning's steps live in a file beside the skill**: Why: the skill's main file has a word budget, and only a run that learns needs them. Not growing the main file.
- **Misfires come from every session, corrections only from your chosen repos**: Why: a skill misfire is about the plugin wherever it happened; a rule belongs to one repo. Not limiting misfires to chosen repos.
- **A wbc skill's misfire is an issue, never a Learned line**: Why: the fix belongs in the plugin, for everyone. Not patching it per repo.
- **Skill issues are invented, then filed only on your OK**: Why: the plugin is public, and sessions hold private work. Not quoting sessions, even redacted.
