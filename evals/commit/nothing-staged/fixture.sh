#!/bin/sh
set -e
git init -q -b main
git config user.name dev
git config user.email dev@example.com
mkdir -p src
printf "export function login(user, password) {\n  return checkPassword(user, password);\n}\n" > src/login.js
git add -A && git commit -qm init
git checkout -qb feature/PROJ-142-login-limit
cat > src/login.js <<'X'
const attempts = new Map();

export function login(user, password) {
  const n = attempts.get(user) ?? 0;
  if (n >= 5) throw new Error("Too many attempts, try again later");
  const ok = checkPassword(user, password);
  attempts.set(user, ok ? 0 : n + 1);
  return ok;
}
X
