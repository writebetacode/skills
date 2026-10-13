# Sourced by fixtures (from evals/<skill>/<case>/fixture.sh): a repo whose origin is a local bare repo,
# and fake `gh`, `glab` and `acli` that check.py puts first on PATH via .eval-bin/. See each for the state it reads.
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
  real_git
}

# macOS /usr/bin/git* are xcrun shims whose cache write the eval sandbox blocks; their errors in git's
# output read as real failures (ticket-asks-tracker, release-prepares-changelog flaked on them). Run the
# real binaries instead; fetch and push from the local remote start the pack programs by name.
real_git() {
  if real=$(xcrun --find git 2>/dev/null); then
    mkdir -p .eval-bin
    for b in git git-upload-pack git-receive-pack; do ln -sf "$(dirname "$real")/$b" .eval-bin/$b; done
  fi
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

# GitLab instead of GitHub: origin's URL names gitlab (a link to the same bare repo), so skills pick GitLab.
# Call before publish.
fake_glab() {
  ln -s .remote.git .gitlab.git
  printf '.gitlab.git\n.fake-glab/\n' >> .git/info/exclude
  git remote set-url origin "$PWD/.gitlab.git"
  mkdir -p .eval-bin .fake-glab
  cp "$LIB/glab" .eval-bin/glab
  chmod +x .eval-bin/glab
  : > .fake-glab/calls.log
}

fake_acli() {
  mkdir -p .eval-bin .fake-acli
  cp "$LIB/acli" .eval-bin/acli
  chmod +x .eval-bin/acli
  printf '.fake-acli/\n' >> .git/info/exclude
  : > .fake-acli/calls.log
}
