GitLab, via `glab` ≥1.115.0 (missing → install from <https://gitlab.com/gitlab-org/cli>; stop). Never add a flag not shown; on failure, report glab's error.

| Operation | Command |
| --- | --- |
| merged | `glab mr list --merged --per-page 20 --output json` (`.title`) |
| view | `glab mr view <branch> --output json` (`iid`, `title`, `description`, `state`, `draft`, `web_url`, `target_branch`) |
| issue | `glab issue view <n> --output json` (`title`, `web_url`) |
| user | `glab api user \| jq -r .username` |
| create | `glab mr create --yes --title <title> --description-file <file> --target-branch <base> --source-branch <branch> --assignee <user>`, plus `--draft` if asked |
| edit-body | `glab mr update <iid> --description-file <file>` |
| edit-title | `glab mr update <iid> --title <title>`, plus `--draft` if it's a draft (else the title loses GitLab's draft prefix) |
| draft | `glab mr update <iid> --draft` |
| ready | `glab mr update <iid> --ready` |
| edit-base | `glab mr update <iid> --target-branch <branch>` |
| checks | `glab ci status --branch <branch> --wait`: final status passed/success → passed; no pipeline → passed; else failed |
| failed jobs | `glab ci get --branch <branch> --with-job-details --output json` (jobs whose `status` is `failed`: `id`, `name`) |
| ci-log | `glab ci trace <job id>` |
| merge | squash: `glab mr merge <iid> --yes --auto-merge=false --squash --squash-message "$(cat <file>)" --remove-source-branch`; merge commit: the same without `--squash` and `--squash-message` |

`glab mr merge` turns on auto-merge by default and returns before merging; `--auto-merge=false` merges now.
