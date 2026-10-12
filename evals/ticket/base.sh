# Sourced by ticket fixtures: a shop repo on main, origin published, fake gh.
. "$(dirname "$0")/../../lib/setup.sh"
repo_with_remote main
mkdir -p src
printf "export const cartTotal = (items) => items.map((i) => i.price).reduce((a, b) => a + b);\n" > src/cart.js
git add -A && git commit -qm "feat: Add cart total"
publish
fake_gh
