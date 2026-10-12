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

#### wbc:commit

Commits what's staged as a conventional commit, scoped to the ticket in the branch name, with bullets that say why. Call it whenever you'd otherwise write a commit message yourself.
