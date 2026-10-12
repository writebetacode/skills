# Sourced by review fixtures: on main; PR #7 (refs/pull/7/head only) adds a name search that builds SQL from input. Sets $head.
. "$(dirname "$0")/../../lib/setup.sh"
repo_with_remote main
mkdir -p src
printf '%s\n' 'const db = require("./db");' '' 'exports.findUserByEmail = (email) =>' '  db.query("SELECT * FROM users WHERE email = ?", [email]);' '' 'exports.findUserById = (id) =>' '  db.query("SELECT * FROM users WHERE id = ?", [id]);' > src/users.js
git add -A && git commit -qm "feat: Add user lookups"
publish
git checkout -qb feat/name-search
printf '%s\n' '' 'exports.findUsersByName = (name) =>' "  db.query(\`SELECT * FROM users WHERE name LIKE '%\${name}%'\`);" >> src/users.js
git commit -qam "feat: Search users by name"
git push -q origin HEAD:refs/pull/7/head
head=$(git rev-parse HEAD)
git checkout -q main
git diff main feat/name-search > pr.diff.tmp
git branch -qD feat/name-search
fake_gh
mv pr.diff.tmp .fake-gh/pr.diff
jq -n --arg h "$head" '{number:7,title:"feat: Search users by name",body:"Lets admins find users by part of their name.",author:{login:"sam"},headRefName:"feat/name-search",baseRefName:"main",headRefOid:$h,state:"OPEN",isDraft:false,url:"https://github.com/acme/shop/pull/7",comments:[]}' > .fake-gh/pr.json
