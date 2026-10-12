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
