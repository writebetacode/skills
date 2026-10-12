GitHub, via `gh` (missing → install from <https://cli.github.com>; stop). Never add a flag not shown; on failure, report gh's error.

| Operation | Command |
| --- | --- |
| merged | `gh pr list --state merged --limit 20 --json title` |
| view | `gh pr view <branch> --json number,title,body,state,isDraft,url` |
| issue | `gh issue view <n> --json title,url` |
| create | `gh pr create --title <title> --body-file <file> --base <default> --head <branch> --assignee @me`, plus `--draft` if asked |
| edit-body | `gh pr edit <n> --body-file <file>` |
| edit-title | `gh pr edit <n> --title <title>` |
| draft | `gh pr ready <n> --undo` |
| ready | `gh pr ready <n>` |
| checks | `gh pr checks <n> --watch`: exit 0 → passed; "no checks reported" → passed; else failed |
| merge | squash: `gh pr merge <n> --squash --subject <subject> --body-file <file> --delete-branch`; merge commit: `gh pr merge <n> --merge --delete-branch` |
