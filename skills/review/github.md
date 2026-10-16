GitHub, via `gh` (missing → install from <https://cli.github.com>; stop). Never add a flag not shown; on failure, report gh's error. `{owner}`/`{repo}` stay literal; gh fills them.

| Operation | Command |
| --- | --- |
| view | `gh pr view <n> --json number,title,body,author,headRefName,baseRefName,headRefOid,state,url` |
| diff | `gh pr diff <n>` |
| fetch-ref | `git fetch origin refs/pull/<n>/head` |
| threads | `gh api graphql -F owner='{owner}' -F name='{repo}' -F n=<n> -f query='query($owner:String!,$name:String!,$n:Int!){repository(owner:$owner,name:$name){pullRequest(number:$n){reviewThreads(first:100){nodes{isResolved path line comments(first:50){nodes{databaseId author{login} body url createdAt}}}}}}}'` |
| comments | `gh pr view <n> --json comments` (general comments: no line, no resolved state) |
| batch | `gh api --method POST repos/{owner}/{repo}/pulls/<n>/reviews --input <json>`, then `reply` for each reply; unanchored → `gh pr comment <n> --body-file <file>` |
| reply | `gh api --method POST repos/{owner}/{repo}/pulls/<n>/comments/<thread's first comment databaseId>/replies -F body=@<file>` |
| approve | `"event": "APPROVE"` in `batch`; alone: `gh pr review <n> --approve` |

`batch` JSON, built with `jq -n --rawfile`, never by hand: `{"commit_id": "<head sha>", "event": "COMMENT" | "APPROVE" | "REQUEST_CHANGES", "comments": [{"path": "<path>", "line": <n>, "side": "RIGHT", "body": <body>}]}`; `"side": "LEFT"` for a removed line.

- Each line must be in the diff. One rejected entry fails the whole review: report it; stop; never resubmit without it.
- A missing-body error → report it; never add a summary.
