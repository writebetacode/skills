#!/bin/sh
set -e
. "$(dirname "$0")/../../lib/setup.sh"
repo_with_remote main
mkdir -p src
printf 'exports.total = (items) => items.length ? items.reduce((s, i) => s + i.price, 0) : null;\n' > src/cart.js
git add -A && git commit -qm "feat: Add cart total"
fake_glab
publish
echo "Checkout shows a null total for an empty cart" > .fake-glab/issue-142
git checkout -qb fix/142-empty-cart-total
printf 'exports.total = (items) => items.reduce((s, i) => s + i.price, 0);\n' > src/cart.js
git commit -qam "fix(#142): Total empty carts as zero" -m "- Checkout showed \"Total: null\" for an empty cart"
