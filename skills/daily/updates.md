Update PRs (Plan step 1), in each active repo (`<this skill's base directory>/active-repos.sh`). Host: `<this skill's base directory>/../../bin/host.sh` there (fails → `Not checked: <repo>: <why>`, never ask); `<owner/name>` from its `origin`. Remote commands only from this table; one refused → `Not checked`.

| Need | Command |
| --- | --- |
| GitHub: update PRs | `gh pr list --repo <owner/name> --state open --limit 200 --json number,title,url,headRefName`, keeping `headRefName` starting `dependabot/` or `renovate/` |
| GitLab: update MRs | `glab api --hostname <host> "projects/<url-encoded path>/merge_requests?state=opened&per_page=100"`, keeping `source_branch` starting `dependabot/` or `renovate/` |

Each update PR → its own item under Updates.
