#!/bin/sh
set -e
. "$(dirname "$0")/../base.sh"
lockout "$(printf 'ticket: ABC-77\nspec: draft')"
cat > "$dir/research/login-today.md" <<'X'
## Request
How login works today and where a lockout would fit (as given).

## Answer
`POST /login` is `exports.login` (src/auth/login.js:4): it looks the user up by email and answers 401 `{ error: "Wrong email or password" }` on a mismatch (src/auth/login.js:6-8). Nothing records failed attempts. acme/web posts its login form to `/login` and shows the response's `error` (CLAUDE.md:2).

## Assumptions
None.

## Adjacent
None.

## Not found
- A cache or Redis client. Tried: grep "redis|cache" in src.
X
