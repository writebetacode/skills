#!/bin/sh
set -e
. "$(dirname "$0")/../bug.sh"
# A finished investigation: notes in .ai/plan/empty-cart-null/research/, no findings.md yet.
D=.ai/plan/empty-cart-null/research
mkdir -p $D
printf '*\n' > .ai/.gitignore
cat > $D/git-history.md <<'X'
# Git history of the cart total

- `git log --oneline -- src/cart.js`:
  ```
  <hash> perf: Skip empty carts early
  <hash> feat: Add cart total
  ```
- `git show HEAD -- src/cart.js` adds `if (items.length === 0) return null;` at src/cart.js:2.
- src/checkout.js:2 prints `Total: ${total(items)}`, so a null total shows as "Total: null".
X
cat > $D/reproduce.md <<'X'
# Reproduce

- `node -e 'console.log(require("./src/checkout").summary([]))'` prints `Total: null`.
- `node -e 'console.log(require("./src/checkout").summary([{price:2,qty:3}]))'` prints `Total: 6`.
- Before `perf: Skip empty carts early`, `total([])` reduced from 0 and returned 0.
X
