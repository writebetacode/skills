#!/bin/sh
set -e
git init -q --bare -b main .remote.git
git init -q -b main
git config user.name dev
git config user.email dev@example.com
echo ".remote.git/" >> .git/info/exclude
printf "export function login(user, password) {\n  return checkPassword(user, password);\n}\n" > login.js
git add -A && git commit -qm "feat: Add login"
git remote add origin "$PWD/.remote.git"
git push -q -u origin main
# A teammate already pushed this branch.
git push -q origin main:refs/heads/feat/abc-123-login-lockout
git update-ref -d refs/remotes/origin/feat/abc-123-login-lockout
