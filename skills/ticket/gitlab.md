GitLab, via `glab` ≥1.115.0 (missing → install from <https://gitlab.com/gitlab-org/cli>; stop). Never add a flag not shown; on failure, report glab's error.

| Operation | Command |
| --- | --- |
| user | `glab api user \| jq -r .username` |
| project id | `glab repo view --output json --jq .id` |
| view | `glab issue view <n> --output json` (`iid`, `title`, `description`, `state`, `labels`, `assignees`, `web_url`) |
| list | `glab issue list --per-page 20 --output json` (`iid`, `title`, `state`, `assignees`, `web_url`), plus as needed: `--search <text>`, `--assignee <user\|@me>`, `--label <a,b>`, `--closed` or `--all` |
| create | `glab issue create --yes --title <title> --description-file <file> --assignee <user>`, plus `--label <a,b>`, `--epic <id>` (parent is an epic, `&<id>`), `--linked-issues <iid,…> --link-type <relates_to\|blocks\|is_blocked_by>` as needed |
| edit | `glab issue update <n>`, plus as needed: `--title <title>`, `--description-file <file>`, `--label`/`--unlabel <a,b>`, `--assignee +<user>`/`--assignee -<user>` |
| link | `glab api projects/:id/issues/<n>/links -F target_project_id=<project id> -F target_issue_iid=<other> -f link_type=<relates_to\|blocks\|is_blocked_by>` |
| comment | `glab issue note <n> --message "$(cat <file>)"` |
| close | `glab issue close <n>` |
| reopen | `glab issue reopen <n>` |

- Native links: related; blocks/blocked by and epics on paid tiers only. Parent issue → body line.
- `--linked-issues` takes one `--link-type` per create; other types → `link` after.
- `--assignee` without `+`/`-` replaces every assignee.
