#!/bin/sh
set -e
git init -q -b main
git config user.name dev
git config user.email dev@example.com
mkdir -p src/auth test .ai/sdlc/login-lockout
cat > src/auth/login.js <<'X'
const db = require("../db");
const { verify } = require("./password");

exports.login = async (req, res) => {
  const user = await db.users.findByEmail(req.body.email);
  if (!user || !(await verify(req.body.password, user.passwordHash))) {
    return res.status(401).json({ error: "Wrong email or password" });
  }
  res.json({ token: await db.sessions.create(user.id) });
};
X
git add -A && git commit -qm "feat: Add login"
# Uncommitted task work: the right password skips the lock check; no test for it.
cat > src/auth/login.js <<'X'
const db = require("../db");
const { verify } = require("./password");

const MAX_FAILS = 5;
const LOCK_MS = 15 * 60 * 1000;

exports.login = async (req, res) => {
  const user = await db.users.findByEmail(req.body.email);
  if (user && (await verify(req.body.password, user.passwordHash))) {
    await db.users.update(user.id, { failedLogins: 0 });
    return res.json({ token: await db.sessions.create(user.id) });
  }
  if (user && user.lockedUntil > Date.now()) {
    const minutesLeft = Math.ceil((user.lockedUntil - Date.now()) / 60000);
    return res.status(423).json({ error: "Account locked", minutesLeft });
  }
  if (user) {
    const failedLogins = user.failedLogins + 1;
    await db.users.update(user.id, {
      failedLogins,
      lockedUntil: failedLogins >= MAX_FAILS ? Date.now() + LOCK_MS : user.lockedUntil,
    });
  }
  return res.status(401).json({ error: "Wrong email or password" });
};
X
cat > test/login.test.js <<'X'
const test = require("node:test");
const assert = require("node:assert");
const { login } = require("../src/auth/login");
const { fakeDb, fakeRes } = require("./fakes");

test("locks after five failures", async () => {
  const db = fakeDb({ failedLogins: 4 });
  await login({ body: { email: "a@b.c", password: "wrong" } }, fakeRes());
  assert.ok(db.user.lockedUntil > Date.now());
});
X
printf '*\n' > .ai/.gitignore
cat > .ai/sdlc/login-lockout/spec.md <<'X'
# Lock accounts after repeated failed logins

After 5 failed logins in a row, an account locks for 15 minutes; while locked, every login is refused.

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
```

## Design

The login handler checks the lock before the password, keeping a failed-login count and a locked-until time on the user's row.
X
