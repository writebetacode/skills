# Setup skill and a record of proposed improvements

A new `setup` skill walks you through everything the other skills read from your machine: the command-line tools, which of your repos depend on each other, and how to reach each repo's logs and errors. Today you write those sections by hand from README examples, so most people never do, and `plan` and `review` miss repos the change touches. This also adds `docs/proposed-improvements.md`, so ideas we've turned down stay turned down.

## Context

`plan` and `review` read `## Related repos` and `## Debug tools` from a repo's `CLAUDE.md` or `CLAUDE.local.md`; `plan`'s task writer reads `## Related repos` from `CLAUDE.md` only. The README tells people to write these sections themselves. The skills call `gh`, `glab`, `acli` and `jq`, and only find out a tool is missing or logged out when a command fails halfway through a job.

Claude Code loads `CLAUDE.local.md` next to `CLAUDE.md` but doesn't ignore it in git for you. It also counts as a `CLAUDE.md`, so adding one to a repo that only has `AGENTS.md` stops Claude reading `AGENTS.md`, unless the new file imports it. A gitignored `CLAUDE.local.md` exists only in the worktree where it was made.

Skills in this repo write into the repos they work on only under `.ai/`, and never under `.claude/` or `.git/`, which Claude Code protects.

## Scope

In: the `setup` skill (CLI checks, related repos, debug tools); reading `## Related repos` from `CLAUDE.local.md` in `plan`'s task writer; `docs/proposed-improvements.md`, its rule in AGENTS.md and a check for it; the README.
Out: `daily`'s sources (added with `daily`); installing or logging in to CLIs for the user; editing a repo's committed `CLAUDE.md`, `AGENTS.md` or `.gitignore`.

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

Scenario: Nothing is written before you confirm
  Given setup has worked out links and debug tools
  When you haven't confirmed them yet
  Then no file has changed

Scenario: Run it again to add a repo
  Given web and api are already linked, and you added a line of your own to web's Related repos
  When you run setup again and add ~/code/acme/billing, which api calls
  Then api and billing gain entries for each other
  And every existing line, yours included, stays exactly as it was

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

Scenario Outline: Proposed improvements stay honest
  Given docs/proposed-improvements.md has a row for <idea> marked <status>
  When the repo's checks run
  Then they <result>

  Examples:
    | idea                         | status    | result                                     |
    | a skill that exists          | Done      | pass                                       |
    | a skill that doesn't exist   | Done      | fail: it says done but there's no skill    |
    | a skill that exists          | Rejected  | fail: a rejected idea got built            |
    | anything                     | Someday   | fail: not one of the known statuses        |
```

## Design

**The skill** lives in `skills/setup/`, runs only when you type it, and walks you through these steps, asking one thing at a time:

1. Which repos: specific paths, or a folder whose git repos (up to two levels down) it scans. The repo you're in is always included. On a re-run it also re-reads the repos already listed in those repos' Related repos sections.
2. Which hosts and trackers you use: the hosts behind each repo's `origin`, and whether you use Jira. For each, it checks the CLI is installed and logged in (`gh`, `glab` for that host, `acli` for Jira), plus `jq`. It reports a short checklist and the command to fix each gap.
3. How they relate, from evidence in the code only: package dependencies between them, one calling another's API, shared schemas or message topics, compose files, submodules. More than a few repos are scanned by parallel read-only subagents, one per repo. Each link becomes a line in both repos, in the form the README already shows: the repo's name, its path relative to this repo, and how they relate in a few words.
4. Debug tools, for repos without a section: lines proposed from what the repo shows (cluster manifests, error-tracker config, compose files) and the connected tools in the session, for you to confirm or fill in.
5. It shows the full set of changes per repo and writes nothing until you confirm. Then, per repo, it creates or updates `CLAUDE.local.md`: it adds lines and fixes a changed path, and never removes or rewrites lines already there. A new file in a repo that has `AGENTS.md` and no `CLAUDE.md` starts with an import of `AGENTS.md`. Before the first write, if git doesn't ignore `CLAUDE.local.md`, it offers to add it to your global git excludes file. If you haven't set one, it gives you the command to run, since Claude Code protects git's default location.
6. It replies with the checklist, each file it wrote and what it added, and anything left for you.

`plan`'s task writer reads `## Related repos` from `CLAUDE.local.md` as well as `CLAUDE.md`, like the rest of `plan` and `review`.

**The record** is `docs/proposed-improvements.md`, written for people: a short intro, then one table of ideas with their status (Proposed, Planned, Done, Skipped for now, Rejected) and a note on why. A rule in AGENTS.md says to read it before proposing a skill or agent, never to propose a rejected one again, to add each new idea with the user's verdict, and to mark an idea Done in the PR that ships it. The repo's check script fails on an unknown status, on a Done row naming a `wbc:` skill or agent that doesn't exist, and on a Rejected row naming one that does.

It starts with: `setup` (Done in this PR), `daily` (Planned, absorbing ticket triage), the upgrade path in `plan` (Planned), `spec-checker` (Planned), deploying and watching releases (Rejected), checking changes in the running app (Skipped for now), and release backports, stale-docs checks in `build` and multi-day recaps (Proposed).

**The README** gets a `wbc:setup` section in a new group at the top, and the Related repos and Debug tools examples say `setup` can write them for you. AGENTS.md's rule about where skills write gains `setup`'s `CLAUDE.local.md` as the one exception.

Testing: the check script's new rule is tested with rows that should pass and fail. The skill is checked by the script's budgets and links, and by running it against a scratch folder of repos.

## Decisions

- **Links go in each repo's `CLAUDE.local.md`, both ways**: Why: paths differ per machine and the user didn't want to commit them; both repos need to know about each other for `plan` and `review` to look across. Not the committed `CLAUDE.md`: it would land in every teammate's checkout with your paths.
- **Ignore it through your global git excludes file, after asking**: Why: one change covers every repo and nothing gets committed. Not each repo's `.gitignore`: a committed change in repos setup only reads. Not `.git/info/exclude`: Claude Code protects `.git/`.
- **Import `AGENTS.md` in a new `CLAUDE.local.md`**: Why: otherwise the new file silently stops Claude reading the repo's `AGENTS.md`. Not changing the global setting: it would change behaviour in every repo, not just the ones setup touched.
- **Links come only from evidence in the code, and you confirm them**: Why: a wrong link sends `review` and `plan` into repos that don't matter. Not guessing from names.
- **Add, never remove**: Why: the sections may hold lines you wrote. Not regenerating the section: it would throw your lines away.
- **Only you start it**: Why: it writes into many repos and your git config. Not letting Claude start it.
- **A table with fixed statuses, checked by the script**: Why: "never do it" only sticks if a rejected idea can't quietly come back. Not free-form notes: nothing could check them.

## Questions

- Should setup also write `daily`'s sources? → Yes, but in `daily`'s PR, since `daily` doesn't exist yet.
