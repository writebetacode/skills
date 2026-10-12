#!/bin/sh
set -e
. "$(dirname "$0")/../../lib/setup.sh"
repo_with_remote main
mkdir -p .github src
printf "## What\n\n## Why\n\n## Testing\n" > .github/pull_request_template.md
printf "export function login(user, password) {\n  return checkPassword(user, password);\n}\n" > src/login.js
git add -A && git commit -qm "feat: Add login"
publish
fake_gh
printf '%s\n' "[ABC-12] Add search filters" "[ABC-15] Fix cart total rounding" "[ABC-9] Cache product images" > .fake-gh/merged-titles
git checkout -qb feat/abc-123-login-lockout
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
git commit -qam "feat(ABC-123): Lock out login after 5 failed attempts" -m "- Stop brute-force guessing of user passwords" -m "Co-Authored-By: Claude Opus 5.5, high effort, 2026-10-12"
printf "test('locks after 5 failures', () => {});\ntest('resets on success', () => {});\n" > src/login.test.js
git add -A && git commit -qm "test(ABC-123): Cover lockout and reset" -m "- A correct password must clear the count"
