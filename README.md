# writebetacode/skills

Claude Code skills for engineering productivity: small, single-purpose and lean, each pinned by quick evals so it does its one job the same way every time.

## Install

```sh
claude plugin marketplace add writebetacode/skills
claude plugin install wbc@writebetacode
```

Invoke a skill as `/wbc:<skill>`.

## Skills

### productivity

#### wbc:same-page

Internal: only other skills call it. Before any work starts, it plays a request back in plain words, with examples that would expose a misreading, until you confirm it.

#### wbc:research

Looks into a question across the code, docs, web and connected tools, then returns a cited report and changes nothing. Call it before deciding or acting: how something works here, which pattern to follow, which versions are in use.

#### wbc:prompt-writer

Writes or tightens text an agent reads (skills, agents, prompts, subagent briefs), keeping only lines that change the agent's behavior. Call it to draft a new skill or slim an existing prompt without losing any of its rules.

#### wbc:voice

Writes anything a person reads in one plain, friendly voice, without AI tells like em dashes, filler or hype. Call it to draft a reply, write a note or doc, or explain terse output in plain English. The other skills use it for their commits, PRs, tickets, reviews, changelogs and specs.

#### wbc:commit

Commits what's staged as a conventional commit, scoped to the ticket in the branch name, with bullets that say why. Call it whenever you'd otherwise write a commit message yourself.

#### wbc:branch

Creates a branch off the freshly fetched default branch, or off a branch you name to stack on, named `<type>/<ticket>-<short-name>` unless you give a name, and never stashes or discards your changes. Call it to start any piece of work.

#### wbc:pr

Opens, updates, drafts, readies or merges the GitHub pull request or GitLab merge request for the current branch, titling it in the repo's own style and squashing by default; it can target a branch to stack on and list MRs that must merge in order. Call it when work is ready for review or merge.

#### wbc:release

Cuts a semver release from conventional commits in two passes: first it drafts the changelog and version bump on a release branch for you to edit, then it opens, merges, tags and publishes the release. Call it when it's time to ship a version.

#### wbc:ticket

Creates, edits, comments on, links, assigns, closes or reopens GitHub and GitLab issues and Jira work items. Tickets say what was seen and why it matters, never how to fix it. Call it to file or update a ticket without leaving your session.

#### wbc:review

Reviews a GitHub pull request or GitLab merge request into `.ai/reviews/<number>.md`, where everything under `.ai/` is ignored by git, with every finding re-checked by a second agent before you read it. Run it again to pick up new pushes and replies, withdraw what you don't want, then tell it to post; findings are inquisitive [Conventional Comments](https://conventionalcomments.org/), and it approves only when asked. Other skills can also ask it for a local review of uncommitted changes against a spec, which returns the findings and writes or posts nothing.

To have it check repos that depend on this one, list them in the repo's `CLAUDE.md` or `CLAUDE.local.md` (`sdlc-plan` reads the same list):

```md
## Related repos
- acme/web (../web): imports `@acme/cart`; calls `/api/cart/*`
```

#### wbc:sdlc-plan

Plans a feature, bug fix, research request or epic into `.ai/sdlc/<name>/`. It agrees the request with you, researches quietly, writes a self-contained spec for you to approve, then splits the spec into commit-sized tasks grouped into merge requests in merge order. Call it before building anything bigger than a quick fix, or to turn a ticket into a plan.

#### wbc:sdlc-build

Builds a plan from `sdlc-plan` one task at a time: tests first, then the code, then a fresh agent reviews the change against the spec, and it stops for you to look before each commit. After the last commit it opens the merge requests in merge order, stacked where the plan says, and archives the plan to `.ai/sdlc/completed/` once you say it's done. A change to what the spec says goes back to `sdlc-plan`. Call it to build, continue or finish planned work.
