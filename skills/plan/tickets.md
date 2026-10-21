`tickets/NN-<mr>.md`, for people (the voice line applies): one per MR, NN = merge order, its tasks file's NN: that MR's slice of the specs, its what and why, and the ACs its tasks target. Never how. Written per [../ticket/templates.md](../ticket/templates.md), its kind's template, so filing it needs no rewrite.

ACs: observable, each in exactly one ticket. ✗ `SavedSearch rows persist` ✓ `A saved search reruns with its filters`. From the plan's `specs/` alone, per spec only its change since its `spec:` line commit (`git show <commit>:<path>` in its repo; missing → new): new → each behaviour; edited → each behaviour added or changed, each removal Out of scope names (AC: behaviour gone); slimmed, reworded or merged → none. An area specced as it is → none.

Where nothing can fail first, a fixed AC, verbatim:

- ships only specs: `specs ship (docs only: no new test)`;
- changes no behaviour (a split's refactor): `suite passes (no behaviour change: no new test)`;
- bumps a dependency ([tasks.md](tasks.md)): `<package> <to>: suite passes (the bump is config: no new test)`, plus one tested AC per breaking change.

A repo whose specs change but that gets no ticket → one ticket there, shipping them.
