Security (Plan step 1), in each active repo (`<this skill's base directory>/active-repos.sh`), at every severity. Host: `<this skill's base directory>/../../bin/host.sh` there (fails → `Not checked: <repo>: <why>`, never ask); `<owner/name>` from its `origin`. Remote commands only from this table; one refused → `Not checked`. GitLab alerts empty → `Not checked: <repo>: none shown; GitLab lists them only on Ultimate`.

| Need | Command |
| --- | --- |
| GitHub: alerts | `gh api --paginate "repos/<owner/name>/dependabot/alerts?state=open&per_page=100"` (`security_advisory.summary`, `security_vulnerability.package.name`, `.vulnerable_version_range`, `.first_patched_version.identifier`, `html_url`) |
| GitHub: update PRs | `gh pr list --repo <owner/name> --state open --limit 200 --json number,title,url,headRefName`, keeping `headRefName` starting `dependabot/` or `renovate/` |
| GitLab: alerts | `glab api --hostname <host> graphql -f query='query{project(fullPath:"<path>"){vulnerabilities(state:[DETECTED,CONFIRMED],first:100){nodes{title severity webUrl location{...on VulnerabilityLocationDependencyScanning{dependency{version package{name}}}}}}}}'` |
| GitLab: update MRs | `glab api --hostname <host> "projects/<url-encoded path>/merge_requests?state=opened&per_page=100"`, keeping `source_branch` starting `dependabot/` or `renovate/` |

Each vulnerable package: check every other active repo's manifests and lockfiles for an affected version; one item under Security lists every repo hit, with `/wbc:plan` to fix them together. Each update PR → its own item under Security.
