#!/bin/sh
set -e
. "$(dirname "$0")/../../lib/setup.sh"
repo_with_remote main
mkdir -p src
printf "export function total(cart) {\n  return cart.total;\n}\n" > src/cart.js
git add -A && git commit -qm "feat: Add cart total"
publish
fake_gh
git checkout -qb fix/142-null-cart-total
printf "export function total(cart) {\n  return cart.total ?? 0;\n}\n" > src/cart.js
git commit -qam "fix(#142): Treat a missing cart total as zero" -m "- Empty carts sent null totals to the payment API" -m "Co-Authored-By: Claude Opus 5.5, high effort, 2026-10-10"
printf "test('empty cart totals 0', () => {});\n" > src/cart.test.js
git add -A && git commit -qm "test(#142): Cover empty carts" -m "- Null totals slipped past review twice" -m "Co-Authored-By: Claude Opus 5.5, high effort, 2026-10-11"
printf "export const isRetry = (event) => event.attempt > 1;\n" > src/webhook.js
git add -A && git commit -qm "fix(#142): Skip charging on webhook retries" -m "- The payment provider retries webhooks on timeout, charging twice"
git push -q -u origin fix/142-null-cart-total
jq -n '{number:7,title:"fix(#142): Stop double-charging empty carts",body:"<!-- pr-body:start -->\n## Tickets\n- [#142](https://github.com/acme/shop/issues/142) Null cart total\n<!-- pr-body:end -->\n",state:"OPEN",isDraft:false,url:"https://github.com/acme/shop/pull/7",headRefName:"fix/142-null-cart-total",baseRefName:"main"}' > .fake-gh/pr.json
echo pass > .fake-gh/checks
# Packed refs: graders read packed-refs to see branch deletion (file_exists can't see fixture files).
git pack-refs --all
git --git-dir=.remote.git pack-refs --all
