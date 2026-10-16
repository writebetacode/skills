Jira, via `acli` (missing → install from <https://developer.atlassian.com/cloud/acli/>; stop). Never add a flag not shown, never `--jql` or `--filter` outside `search`, never `--from-file`, `--from-json` or `--editor`; on failure, report acli's error. Project key: the key's prefix (`ABC-123` → `ABC`).

| Operation | Command |
| --- | --- |
| view | `acli jira workitem view <key> --fields key,issuetype,summary,status,assignee,labels,parent,issuelinks,description --json` |
| search | `acli jira workitem search --jql <jql> --limit 20 --fields key,summary,status,assignee --json` |
| create | `acli jira workitem create --project <KEY> --type <type> --summary <summary> --description-file <file> --assignee @me --json`, plus `--label <a,b>`, `--parent <key>` as needed |
| edit | `acli jira workitem edit --key <key> --yes --json`, plus as needed: `--summary <summary>`, `--description-file <file>`, `--labels <a,b>`, `--remove-labels <a,b>`, `--type <type>` |
| assign | `acli jira workitem assign --key <key> --assignee <email\|@me> --yes --json`, or `--remove-assignee` instead of `--assignee` |
| comment | `acli jira workitem comment create --key <key> --body-file <file> --json` |
| transition | `acli jira workitem transition --key <key> --status <status> --yes --json`; close → `Done`, reopen → `To Do`, unless named |
| in progress | `search` with `--jql 'key = <key> AND statusCategory = "In Progress"'`: a result → in progress |
| link types | `acli jira workitem link type --json` |
| link | `acli jira workitem link create --out <key> --in <key> --type <type> --yes`; `--out` blocks `--in`: ABC-2 blocked by ABC-1 → `--out ABC-1 --in ABC-2 --type Blocks` |

- Native links: blocks, blocked by, related (`Relates`); parent at create only, later → body line. Link type not in `link types` → body line.
- Type or status rejected → report it; ask, never guess another.
