#!/bin/sh
set -e
. "$(dirname "$0")/../base.sh"
mkdir -p .ai/reviews
printf '*\n' > .ai/.gitignore
cat > .ai/reviews/7.md <<MD
# PR #7: feat: Search users by name
<!-- reviewed at $head -->

## 1. suggestion (non-blocking): src/users.js:10
posted: 2026-10-12 https://github.com/acme/shop/pull/7#discussion_r101

The ask: Should \`findUsersByName\` cap how many rows it returns?

A short name like "a" matches most users, and the admin page renders every row.

## 2. issue (blocking): src/users.js:10

The ask: Could a name like \`' OR '1'='1\` change which rows this query returns?

\`findUsersByName\` puts \`name\` straight into the SQL string, while the lookups above pass values as parameters (src/users.js:4, src/users.js:7). Anyone who can search could read every user.

Example:
\`\`\`js
findUsersByName("' OR '1'='1") // returns every user
\`\`\`

## 3. question (non-blocking): src/users.js:9

The ask: Is the admin page the only caller of \`findUsersByName\`, or can signed-out visitors reach it too?

The description says admins only, and nothing in this PR checks who is searching.

## Withdrawn
### 4. nitpick (non-blocking): src/users.js:9

The ask: Would \`searchUsers\` read better than \`findUsersByName\`?
MD
# The earlier review's checkout, left for Post to clean up.
git worktree add -q --detach "$(mktemp -d)/review-shop-7" "$head"
