#!/bin/sh
set -e
mkdir -p skills/deploy
cat > skills/deploy/SKILL.md <<'X'
---
name: deploy
description: This skill should be used in order to deploy the app to staging whenever the user would like to deploy it.
---

When asked to deploy, it is very important that you first run the test suite with `npm test`, and if any of the tests happen to fail you should stop right there and not continue.
After that, please go ahead and run `./scripts/deploy.sh staging` in order to deploy.
Please make sure you never, under any circumstances, deploy to production, even if the user asks you to.
X
