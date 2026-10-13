# Sourced by build fixtures: shop repo on origin/main; total([]) returns null; an approved one-task plan
# .ai/plan/empty-cart-total/ for #142, its spec untracked at docs/specs/empty-cart-total.md. `built` puts task 1's fix and test uncommitted on its branch.
. "$(dirname "$0")/../../lib/setup.sh"
repo_with_remote main
mkdir -p src test
printf '{ "name": "shop", "private": true, "scripts": { "test": "node --test" } }\n' > package.json
cat > src/cart.js <<'X'
exports.total = (items) => {
  if (items.length === 0) return null;
  return items.reduce((sum, i) => sum + i.price * i.qty, 0);
};
X
cat > test/cart.test.js <<'X'
const test = require("node:test");
const assert = require("node:assert");
const { total } = require("../src/cart");

test("sums price times quantity", () => {
  assert.strictEqual(total([{ price: 2, qty: 3 }]), 6);
});
X
git add -A && git commit -qm "feat: Add cart total"
publish
fake_gh
# The eval sandbox blocks version-manager node shims; put the real binary first on PATH.
ln -s "$(node -p process.execPath)" .eval-bin/node
P=.ai/plan/empty-cart-total
mkdir -p $P/tasks docs/specs
printf '*\n' > .ai/.gitignore
cat > docs/specs/empty-cart-total.md <<'X'
# Empty carts total zero

An empty cart's total comes back as nothing instead of 0, so checkout shows "Total: null". It should be 0.

## Behaviour

```gherkin
Scenario: Empty cart totals zero
  Given a cart with no items
  When its total is worked out
  Then the total is 0
```

## Design

The cart module's total returns 0 for no items, tested beside the existing cart tests.
X
printf 'ticket: #142\nspec: approved 2026-10-10 docs/specs/empty-cart-total.md\n\n## MRs\n- 01-cart-total: todo\n' > $P/status.md
cat > $P/tasks/01-cart-total.md <<'X'
# 01: Total empty carts as zero
repo: shop .
branch: fix/142-empty-cart-total
base: main
after: none
with: none

## 1. Return 0 for an empty cart
`total` in src/cart.js; tests in test/cart.test.js.
- [ ] Empty cart totals zero
X
built() {
  git checkout -q -b fix/142-empty-cart-total
  sed -i.bak 's/return null;/return 0;/' src/cart.js && rm src/cart.js.bak
  cat >> test/cart.test.js <<'X'

test("Empty cart totals zero", () => {
  assert.strictEqual(total([]), 0);
});
X
  sed -i.bak 's/01-cart-total: todo/01-cart-total: building/' $P/status.md && rm $P/status.md.bak
}
