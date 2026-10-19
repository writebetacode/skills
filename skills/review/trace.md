Trace the change to everything it reaches. A break this misses, nothing later finds: the checker only cuts.

1. Read each touched file whole, as the change leaves it (generated and lock files: their hunks).
2. List every name the diff adds, changes, renames or removes: functions, types, fields, constants, config keys, env vars, flags, CLI args, routes, events, topics, tables, columns, errors and their messages, file paths, permissions. Add each spelling it takes elsewhere (`user_id`, `userId`, `USER_ID`, `user-id`).
3. Search for each, old and removed names too, here (`git grep -n`) and in each related repo (step 2). Read every hit:
   - callers of a changed signature, return value or side effect; what the changed code calls, and what each callee assumes;
   - readers and writers of changed config, env vars and schemas: deploy, CI, Docker and infra files still setting old names; migrations against rows already there; serialized shapes (API responses, stored JSON, messages, cache entries, cookies) still in the old form, written before the deploy or by the other side;
   - code matching changed errors by type, code or message;
   - tests, fixtures, mocks and snapshots still asserting the old behavior;
   - generated, vendored or cached files left stale (clients, lockfiles, built output);
   - docs and specs naming it.
4. Sweep what no name leads to: an error path nothing handles; a removed check, lock or guard something relied on; changed defaults, ordering, timing or concurrency; work bounded before, unbounded now; a bumped dependency's breaking changes against each use here.
5. Settle each hit and question yourself from the code, tests, history (`git log -S`) and ticket. What none settles → a finding asking the author only what they know. Never drop one unsettled.
