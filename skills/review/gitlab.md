GitLab, via `glab` ≥1.122.0. Never add a flag not shown.

| Operation | Command |
| --- | --- |
| view | `glab mr view <n> --output json` (`iid`, `title`, `description`, `author`, `source_branch`, `target_branch`, `sha`, `state`, `web_url`) |
| diff | `glab mr diff <n> --raw` |
| fetch-ref | `git fetch origin refs/merge-requests/<n>/head` |
| threads | `glab mr note list <n> --output json` (discussions with `resolved`; skip system notes) |
| draft | `glab mr note draft create <n> --file <path> --line <line> < <file>`; `--old-line` for a removed line; `--reply <discussion id>` instead for a reply; neither for a general comment |
| batch | `glab mr note draft list <n> --output json` (any existing → report; stop), then `draft` each comment, then `glab mr note draft publish <n> --yes`, plus `--reviewer-state requested_changes` if asked |
| approve | `glab mr approve <n> --sha <head sha>` |
| permalink | `<web_url before /-/merge_requests/>/-/blob/<sha>/<path>#L<a>`, a range `#L<a>-<b>` |
| reply | `glab mr note create <n> --reply <discussion id> --message "$(cat <file>)"` (posts at once) |

Drafts stay private until `publish`; a failed `draft` → report; stop before publishing.
