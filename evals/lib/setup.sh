# Sourced by fixtures (from evals/<skill>/<case>/fixture.sh): a repo whose origin is a local bare repo,
# and a fake `gh` that check.py puts first on PATH via .eval-bin/. See gh for the state it reads.
LIB=$(cd "$(dirname "$0")/../../lib" && pwd)

# $1: default branch. Leaves an empty repo; commit, then `publish`. Reflogs on everywhere: graders check
# .git/logs/refs/..., which exist exactly while the ref does, packed or not.
repo_with_remote() {
  git init -q --bare -b "$1" .remote.git
  git --git-dir=.remote.git config core.logAllRefUpdates always
  git init -q -b "$1"
  git config core.logAllRefUpdates always
  git config user.name dev
  git config user.email dev@example.com
  printf '.remote.git/\n.eval-bin/\n.fake-gh/\n' >> .git/info/exclude
  git remote add origin "$PWD/.remote.git"
  # macOS /usr/bin/git is an xcrun shim whose cache write the eval sandbox blocks; its errors in every git
  # call's output read as real failures (ticket-asks-tracker flaked on it). Run the real binary instead.
  if real=$(xcrun --find git 2>/dev/null); then mkdir -p .eval-bin && ln -sf "$real" .eval-bin/git; fi
}

# Push the current (default) branch and record it as origin/HEAD.
publish() {
  git push -q -u origin HEAD
  git remote set-head origin -a > /dev/null
}

fake_gh() {
  mkdir -p .eval-bin .fake-gh
  cp "$LIB/gh" .eval-bin/gh
  chmod +x .eval-bin/gh
  : > .fake-gh/calls.log
}
