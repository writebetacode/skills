# Sourced by sdlc-plan fixtures: an API repo with a login handler; acme/web listed as a related repo.
git init -q -b main
git config user.name dev
git config user.email dev@example.com
mkdir -p src/auth
cat > src/auth/login.js <<'X'
const db = require("../db");
const { verify } = require("./password");

exports.login = async (req, res) => {
  const user = await db.users.findByEmail(req.body.email);
  if (!user || !(await verify(req.body.password, user.passwordHash))) {
    return res.status(401).json({ error: "Wrong email or password" });
  }
  res.json({ token: await db.sessions.create(user.id) });
};
X
cat > CLAUDE.md <<'X'
## Related repos
- acme/web (../web): its login form posts to `/login` and shows the `error` it gets back
X
git add -A && git commit -qm "feat: Add login"
# lockout <status.md body>: .ai/sdlc/login-lockout/ with that status.md; sets $dir.
lockout() {
  dir=.ai/sdlc/login-lockout
  mkdir -p "$dir/research"
  printf '*\n' > .ai/.gitignore
  printf '%s\n' "$1" > "$dir/status.md"
}
