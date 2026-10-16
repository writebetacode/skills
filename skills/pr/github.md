GitHub, via `gh` (missing → install from <https://cli.github.com>; stop). Never add a flag not shown; on failure, report gh's error.

| Operation | Command |
| --- | --- |
| merged | `gh pr list --state merged --limit 20 --json title` |
| view | `gh pr view <branch> --json number,title,body,state,isDraft,url,baseRefName,author` |
| user | `gh api user --jq .login` |
| issue | `gh issue view <n> --json title,url` |
| create | `gh pr create --title <title> --body-file <file> --base <base> --head <branch> --assignee @me`, plus `--draft` if asked |
| edit-body | `gh pr edit <n> --body-file <file>` |
| edit-title | `gh pr edit <n> --title <title>` |
| draft | `gh pr ready <n> --undo` |
| ready | `gh pr ready <n>` |
| edit-base | `gh pr edit <n> --base <branch>` |
| checks | `gh pr checks <n> --watch`: exit 0 → passed; "no checks reported" → passed; else failed |
| failed jobs | `gh run list --branch <branch> --commit <head sha> --status failure --limit 20 --json databaseId,name,url` (none for checks outside GitHub Actions) |
| ci-log | `gh run view <databaseId> --log-failed` |
| merge | squash: `gh pr merge <n> --squash --subject <subject> --body-file <file> --delete-branch`; merge commit: `gh pr merge <n> --merge --delete-branch` |
