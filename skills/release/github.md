GitHub, via `gh`. Never add a flag not shown.

| Operation | Command or format |
| --- | --- |
| repo URL | `gh repo view --json url --jq .url` |
| compare link | `<repo URL>/compare/<last tag>...v<version>` |
| first-release link | `<repo URL>/commits/v<version>` |
| commit link | `<repo URL>/commit/<full hash>` |
| merge commit | `gh pr view <n> --json mergeCommit --jq .mergeCommit.oid` |
| release | `gh release create v<version> --title v<version> --notes-file <file> --verify-tag` |
