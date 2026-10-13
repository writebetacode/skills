#!/bin/sh
set -e
. "$(dirname "$0")/../base.sh"
# PR 7 is open with the empty-cart test but not the fix, so CI's test job fails on it.
git checkout -q -b fix/142-empty-cart-total
cat >> test/cart.test.js <<'X'

test("Empty cart totals zero", () => {
  assert.strictEqual(total([]), 0);
});
X
git commit -qam "fix(#142): Total empty carts as zero"
git push -q -u origin fix/142-empty-cart-total
cat > .fake-gh/pr.json <<'X'
{"number":7,"title":"fix(#142): Total empty carts as zero","body":"","state":"OPEN","isDraft":false,"url":"https://github.com/acme/shop/pull/7","headRefName":"fix/142-empty-cart-total","baseRefName":"main"}
X
echo fail > .fake-gh/checks
echo '[{"databaseId":901,"name":"test","url":"https://github.com/acme/shop/actions/runs/901"}]' > .fake-gh/runs.json
cat > .fake-gh/run-log <<'X'
test	Run npm test	✖ Empty cart totals zero (0.4ms)
test	Run npm test	  AssertionError [ERR_ASSERTION]: Expected values to be strictly equal:
test	Run npm test	  null !== 0
test	Run npm test	      at TestContext.<anonymous> (test/cart.test.js:10:10)
test	Run npm test	ℹ tests 2  ℹ pass 1  ℹ fail 1
test	Run npm test	##[error]Process completed with exit code 1.
X
