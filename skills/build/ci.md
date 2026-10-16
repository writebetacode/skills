CI (land.md step 3): `checks`. Failed → `failed jobs`, then `ci-log` each; reproduce locally the way the job runs. Code failure → fix per Task step 2, the failing test as its test. Infra or no log → report only.

A failing test that passes locally, its findings folder's `status.md` naming a `fix:` branch → that fix's PR open: still waiting, report this PR's CI as red from it; merged: land.md step 2 rebases this PR. With no findings for it yet in a folder under `<this skill's base directory>/../plan/ai-dir.sh plan` → `plan` skill, unasked, handing over the test, the job and its log, the PR's branch, and its head and base commits (base: `git merge-base origin/<base> HEAD`, `<base>` as in land.md step 2). Its findings say whether the PR's change causes it:

- It does → fix it on this PR's branch per Task step 2; carry on landing.
- It fails the same way at the PR's base → finish this round, reporting the PR's CI as red from it, waiting on that fix. Once this round's Go has committed and pushed, build the fix on its own branch, named from the findings, opened once the user says go; add `fix: <branch>` to the findings folder's `status.md`. That fix merged → land.md step 2 rebases this PR.
- Not reproduced, or no cause found → list it as what's left, with the findings' path.

Either fix is one task only if it fits one PR with nothing left to decide; else hand the findings to `plan` to plan the fix with the user.
