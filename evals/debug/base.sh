# Sourced by debug fixtures: shop repo on main whose last commit made total([]) return null.
. "$(dirname "$0")/../../lib/setup.sh"
repo_with_remote main
mkdir -p src test
printf '{ "name": "shop", "private": true, "scripts": { "test": "node --test" } }\n' > package.json
cat > src/cart.js <<'X'
exports.total = (items) => items.reduce((sum, i) => sum + i.price * i.qty, 0);
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
cat > src/checkout.js <<'X'
const { total } = require("./cart");
exports.summary = (items) => `Total: ${total(items)}`;
X
git add -A && git commit -qm "feat: Show the cart total at checkout"
cat > src/cart.js <<'X'
exports.total = (items) => {
  if (items.length === 0) return null;
  return items.reduce((sum, i) => sum + i.price * i.qty, 0);
};
X
git add -A && git commit -qm "perf: Skip empty carts early"
publish
# The eval sandbox blocks version-manager node shims; put the real binary first on PATH.
ln -s "$(node -p process.execPath)" .eval-bin/node
