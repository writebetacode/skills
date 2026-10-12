GitLab, via `glab` (missing → install from <https://gitlab.com/gitlab-org/cli>; stop). Never add a flag not shown; on failure, report glab's error.

| Operation | Command or format |
| --- | --- |
| repo URL | `glab repo view --output json` (`web_url`) |
| compare link | `<repo URL>/-/compare/<last tag>...v<version>` |
| first-release link | `<repo URL>/-/commits/v<version>` |
| commit link | `<repo URL>/-/commit/<full hash>` |
| merge commit | `glab mr view <iid> --output json` (`merge_commit_sha`) |
| release | `glab release create v<version> --name v<version> --notes-file <file>` |
