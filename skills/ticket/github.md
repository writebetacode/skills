GitHub, via `gh` (missing → install from <https://cli.github.com>; unknown flag → upgrade gh; stop). Never add a flag not shown; on failure, report gh's error. A repo other than the current folder's → `--repo <owner/name>` on each command.

| Operation | Command |
| --- | --- |
| view | `gh issue view <n> --json number,title,body,state,labels,assignees,parent,blockedBy,blocking,url` |
| list | `gh issue list --limit 20 --json number,title,state,assignees,url`, plus as needed: `--search <query>`, `--assignee <login\|@me>`, `--label <a,b>`, `--state <open\|closed\|all>` |
| create | `gh issue create --title <title> --body-file <file> --assignee @me`, plus `--label <a,b>`, `--parent <n>`, `--blocked-by <n,…>`, `--blocking <n,…>` as needed |
| edit | `gh issue edit <n>`, plus as needed: `--title <title>`, `--body-file <file>`, `--add-label`/`--remove-label <a,b>`, `--add-assignee`/`--remove-assignee <login\|@me>`, `--parent <n>`/`--remove-parent`, `--add-blocked-by`/`--remove-blocked-by <n>`, `--add-blocking`/`--remove-blocking <n>` |
| comment | `gh issue comment <n> --body-file <file>` |
| close | `gh issue close <n>`, plus `--reason <completed\|not planned>` if given, or `--duplicate-of <original>` for a duplicate |
| reopen | `gh issue reopen <n>` |

Native links: parent, blocked by, blocking. Related → body line.
