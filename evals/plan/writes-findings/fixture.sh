#!/bin/sh
set -e
. "$(dirname "$0")/../bug.sh"
# An investigation just started: the bug reproduced, the cause not yet looked for.
D=.ai/plan/empty-cart-null/research
mkdir -p $D
printf '*\n' > .ai/.gitignore
cat > $D/reproduce.md <<'X'
# Reproduce

- `node -e 'console.log(require("./src/checkout").summary([]))'` prints `Total: null`.
- `node -e 'console.log(require("./src/checkout").summary([{price:2,qty:3}]))'` prints `Total: 6`.
X
