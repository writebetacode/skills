#!/bin/sh
set -e
. "$(dirname "$0")/../base.sh"
lockout "$(printf 'ticket: ABC-77\nspec: draft')"
printf '## Answer\nCount failures in Redis with a 15-minute TTL.\n' > "$dir/research/lockout-storage.md"
cat > "$dir/spec.md" <<'X'
# Lock accounts after repeated failed logins

Anyone can guess passwords at `/login` without limit. After 5 failed logins in a row, an account locks for 15 minutes, and the web login form says when to try again.

## Context

`POST /login` in this API (`src/auth/login.js`) checks the email and password and answers 401 on a mismatch; nothing counts failures. The web app, `acme/web`, posts its login form there and shows the error it gets back.

## Scope

In: counting failed logins per account, the 15-minute lock, the web message.
Out: unlock emails, limits per IP.

## Behaviour

```gherkin
Scenario: Locked after five failures
  Given an account with 4 failed logins in a row
  When a 5th login fails
  Then the account is locked for 15 minutes

Scenario: Right password refused while locked
  Given a locked account
  When a login sends the right password
  Then the API answers 423 with the minutes left

Scenario: Success resets the count
  Given an account with 3 failed logins in a row
  When a login succeeds
  Then the account's failed count is 0

Scenario: Web says when to try again
  Given the API answers a login with 423 and 12 minutes left
  When the login form shows the result
  Then it reads "Account locked. Try again in 12 minutes."
```

## Design

The API keeps a failed-login count and a locked-until time on each user's row, checks the lock before the password, and answers a locked login with 423 and the whole minutes left. Tested through the login handler's existing tests. The web login form turns a 423 into the message. The API change ships first; the web change follows, and users see the message only once both are out.

## Decisions

- **Lock per account**: one count per user. Why: a shared office IP would lock out everyone. Not per IP: same reason.
- **Count on the user's row**: two fields on the users table. Why: the stack has no cache. Not Redis: a new service for two fields.
X
