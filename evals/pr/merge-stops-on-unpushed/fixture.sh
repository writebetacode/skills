#!/bin/sh
set -e
# The merge-squash-message PR, plus a local commit origin doesn't have; gh's --delete-branch would drop it.
. "$(dirname "$0")/../merge-squash-message/fixture.sh"
printf "export const MAX_ITEMS = 50;\n" > src/limits.js
git add -A && git commit -qm "feat(#142): Cap cart size"
