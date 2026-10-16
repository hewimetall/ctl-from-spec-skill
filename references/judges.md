# Judges

The accepted `docs/superpowers/specs/endpoints.md` and `endpoints/<slug>.md` files are the rubric. Judges do not rediscover urls or routers, do not recompute prefixes, do not reopen handler bodies to invent a new list, and do not replace a constraint with a guess.

A client result passes only when all of these hold:

- Every row in `endpoints.md` is implemented, or the result names that row as skipped.
- The client has no route that is absent from `endpoints.md`.
- Paths in the client are `base` joined with the resolved `path` from the table.
- For each implemented row, every line under `constraints` in `endpoints/<slug>.md` still holds in the diff.
- A `gap` is closed only if this row's spec told the worker to close it. Any other gap stays open.
- Evidence is `.agent/result/patch.diff` and `result.manifest.json`. The judge cites the spec path and the diff, not a fresh crawl.

A miss fails the review. The manager dispatches a fresh SWE to repair that row. The judge does not edit `endpoints.md`. The manager does not repair it either.
