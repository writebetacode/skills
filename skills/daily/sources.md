Never add a flag not shown; on failure, report the CLI's error. `<day>`: YYYY-MM-DD, local time.

GitHub:

| Need | Command |
| --- | --- |
| login | `gh api user --jq .login` |
| review requests | `gh search prs --review-requested=@me --state=open --json number,title,repository,url` |
| your PRs | `gh search prs --author=@me --state=open --json number,title,repository,url,isDraft`; repeat with `--checks=failure`, `--review=changes_requested`, `--review=approved` |
| tickets | `gh search issues --assignee=@me --state=open --json number,title,repository,url,labels` |
| replies owed | `gh api notifications`, skipping reasons `subscribed`, `ci_activity`; link: `subject.url` with `api.github.com/repos/` → `github.com/`, `/pulls/` → `/pull/` |
| activity | `gh api --paginate "users/<login>/events?per_page=100" --jq '.[] \| select((.created_at \| fromdate \| strflocaltime("%Y-%m-%d")) == "<day>") \| {type, repo: .repo.name, payload}'` |

GitLab:

| Need | Command |
| --- | --- |
| login | `glab api --hostname <host> user` (`username`) |
| your MRs | `glab api --hostname <host> "merge_requests?scope=created_by_me&state=opened"` |
| tickets | `glab api --hostname <host> "issues?scope=assigned_to_me&state=opened"` |
| review requests, replies owed | `glab api --hostname <host> "todos?state=pending"`: `action_name` `review_requested` → review, else reply owed |
| activity | `glab api --hostname <host> --paginate "events?after=<day-2>&before=<day+2>"` (`created_at` is UTC) |

Jira:

| Need | Command |
| --- | --- |
| login | `acli jira auth status` |
| tickets | `acli jira workitem search --jql "assignee = currentUser() AND statusCategory != Done ORDER BY priority DESC" --limit 20 --fields key,summary,status,priority --json`; link `https://<site>/browse/<key>`, `<site>`: the site `login` shows, else unlinked |
| activity | `acli jira workitem search --jql "issuekey in updatedBy(currentUser(), '<day>', '<day>')" --limit 50 --fields key,summary,status --json` |
