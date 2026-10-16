# Worker TDD

Discover the repository's test command before the first test. Prefer a Makefile target `test` or `lint`, then a checked-in wrapper. Do not assume `npm test` or `go test ./...` until the tree shows that command.

```text
RED → GREEN → REFACTOR
```

RED. Write the test that states the new behavior or reproduces the bug. Run the repository's focused test command. It must fail. A test that passes immediately proves nothing.

GREEN. Write the smallest change that makes that test pass. Do not add behavior the test does not ask for.

REFACTOR. Clean up while the same tests stay green. Run the focused command after a change that can affect the result. Do not run it again if the code has not changed.

Then run the repository's full suite once before the candidate manifest.

Assert outcomes, not call sequences. One behavior per test. The test name states that behavior.

This file does not pick the CLI language. When the change is Go, handwritten tests follow [go-testing.md](go-testing.md) and the gates in [go-quality.md](go-quality.md). Another language uses the test style that repository already has.

Not this loop: config-only edits, documentation with no behavior change, and generated files marked `Code generated ... DO NOT EDIT`.
