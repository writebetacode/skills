#!/bin/sh
# Four sessions: three on 2026-10-12 (notes jotted outside git first, then shop fix with PR #142, web review), one on
# 2026-10-10 (invoice export); shop is a real repo whose 2026-10-12 commits include a README change no prompt mentions,
# so they show only if the folder outside git doesn't stop the commit listing.
# The case points the recap script at .sessions/ via EVAL_SESSIONS_DIR and sends recaps to the daily note.
set -e
. "$(dirname "$0")/../../lib/setup.sh"
real_git
# N: outside any git repo; the eval sandbox's home, which holds this folder, is one.
S=.sessions R=$PWD/code N=$(mktemp -d)
mkdir -p "$S/-Users-dev-code-shop" "$S/-Users-dev-code-web" "$S/-Users-dev-notes" vault/Daily "$R/shop" "$N/notes"
(
  cd "$R/shop" && git init -q -b main && git config user.name dev && git config user.email dev@example.com
  echo "# shop" > README.md && git add -A && GIT_AUTHOR_DATE=2026-10-11T10:00:00 GIT_COMMITTER_DATE=2026-10-11T10:00:00 git commit -qm "feat: Add shop"
  printf '# shop\n\nnpm install, then npm start.\n' > README.md
  GIT_AUTHOR_DATE=2026-10-12T17:00:00 GIT_COMMITTER_DATE=2026-10-12T17:00:00 git commit -qam "docs: Add install steps to the README"
)
u() { printf '{"type":"user","timestamp":"%s","cwd":"'"$R"'/%s","gitBranch":"%s","sessionId":"%s","isSidechain":false,"message":{"role":"user","content":"%s"}}\n' "$@"; }
a() { printf '{"type":"assistant","timestamp":"%s","cwd":"'"$R"'/%s","gitBranch":"%s","sessionId":"%s","isSidechain":false,"message":{"role":"assistant","content":[{"type":"text","text":"%s"}]}}\n' "$@"; }
{
  u 2026-10-12T14:05:00.000Z shop fix/142-empty-cart-total s1 "build the empty-cart-total plan"
  a 2026-10-12T14:20:00.000Z shop fix/142-empty-cart-total s1 "Task 01-cart-total: Empty cart totals zero, test/cart.test.js:12. Look it over; say go to commit."
  u 2026-10-12T14:30:00.000Z shop fix/142-empty-cart-total s1 "go, then open the PR"
  printf '{"type":"pr-link","sessionId":"s1","prNumber":"142","prUrl":"https://github.com/acme/shop/pull/142","prRepository":"acme/shop","timestamp":"2026-10-12T14:40:00.000Z"}\n'
  a 2026-10-12T14:41:00.000Z shop fix/142-empty-cart-total s1 "Committed and opened https://github.com/acme/shop/pull/142: fix(#142): Total empty carts as zero."
  printf '{"type":"ai-title","aiTitle":"Fix empty cart total","sessionId":"s1"}\n'
} > "$S/-Users-dev-code-shop/s1.jsonl"
(
  R=$N
  u 2026-10-12T13:00:00.000Z notes "" s4 "jot down the agenda for tomorrow's standup"
  a 2026-10-12T13:02:00.000Z notes "" s4 "Added the agenda to standup.md."
) > "$S/-Users-dev-notes/s4.jsonl"
{
  u 2026-10-12T16:00:00.000Z web main s2 "review PR 150"
  u 2026-10-12T16:25:00.000Z web main s2 "post it"
  a 2026-10-12T16:26:00.000Z web main s2 "Posted 2 comments on https://github.com/acme/web/pull/150."
  printf '{"type":"ai-title","aiTitle":"Review web PR 150","sessionId":"s2"}\n'
} > "$S/-Users-dev-code-web/s2.jsonl"
{
  u 2026-10-10T15:00:00.000Z shop main s3 "plan the invoice export"
  a 2026-10-10T15:30:00.000Z shop main s3 "Spec for invoice export written; approve or change?"
  printf '{"type":"ai-title","aiTitle":"Plan invoice export","sessionId":"s3"}\n'
} > "$S/-Users-dev-code-shop/s3.jsonl"
cat > vault/Daily/2026-10-12.md <<'X'
# 2026-10-12

## Claude

## Gym
- Legs
X
