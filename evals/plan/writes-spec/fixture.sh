#!/bin/sh
set -e
. "$(dirname "$0")/../base.sh"
# A committed spec for sign-in that the lockout makes untrue (unlimited retries).
mkdir -p docs/specs
cat > docs/specs/login.md <<'X'
# Sign in with email and password

People sign in with their email and password and get a session token back.

## Scope
In: email and password sign-in.
Out: password resets. Anyone may retry as often as they like.

## Behaviour
```gherkin
Scenario: Wrong password
  Given an account
  When a login sends the wrong password
  Then the API answers 401 "Wrong email or password"
```

## Decisions
- **No attempt limit**: retries are never refused. Why: no abuse seen yet. Not a limit: nothing to justify the support load.
X
git add docs/specs/login.md && git commit -qm "docs: Add the sign-in spec"
lockout "$(printf 'ticket: ABC-77\nspec: draft')"
cat > "$dir/research/login-today.md" <<'X'
## Request
How login works today and where a lockout would fit (as given).

## Answer
`POST /login` is `exports.login` (src/auth/login.js:4): it looks the user up by email and answers 401 `{ error: "Wrong email or password" }` on a mismatch (src/auth/login.js:6-8). Nothing records failed attempts. acme/web posts its login form to `/login` and shows the response's `error` (CLAUDE.md:2).

## Assumptions
None.

## Adjacent
- `docs/specs/login.md` specs sign-in today, including that failed attempts are never limited (docs/specs/login.md:7,19).

## Not found
- A cache or Redis client. Tried: grep "redis|cache" in src.
X
