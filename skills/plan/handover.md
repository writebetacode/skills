A failing CI test handed over by `build` (the test, the CI job and its log, the PR's branch, its head and base commits): the problem is exact, so no `same-page`; name the folder from the test. Follow [investigate.md](investigate.md), reproducing this way in its worktree, at the head commit:

1. The test alone, up to 50 runs, stopping at the first failure. Never fails → the whole suite in CI's order, up to 5 runs.
2. It failed → before patching or logging anything, rerun the same way at the PR's base commit (`git -C <worktree> checkout --detach <it>`), then check the head out again, so the findings say whether the PR's change causes it.
3. Fails sometimes → flaky: prove the cause as usual, the patched code passing the same way the failure was reproduced (50 runs alone, or the 5 suite runs). Never fails → investigate what differs between CI and this machine (versions, settings, services, data) as an ordinary bug. Still no repro → the findings say so, confidence ≤ medium.

Instead of findings-file.md's Reply, reply to `build` with `findings.md`'s path; it carries on landing.
