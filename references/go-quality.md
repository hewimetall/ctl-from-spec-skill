---
name: go-quality
description: >-
  Enforces TDD and the Go gates for handwritten Go in the CLI (commands,
  config, OpenAPI adapters, presenters, tests). Use when implementing or
  reviewing Go changes, regenerating OpenAPI clients, running make test, or
  before the candidate manifest. Generated clients are regenerate-only.
---

# Go quality for the CLI

Read this before editing handwritten Go. Handwritten tests follow [go-testing.md](go-testing.md).

## When to apply

Any change under `cmd/`, `common/`, generator wrappers, or tests. Also when regenerating OpenAPI clients or changing Makefile test targets. Do not hand-edit generated clients. Regenerate them and compile.

## Hard constraints

- Do not modify the service repository that owns the API. Specs are fetched from the local stand into `openapi/.cache/` and are not committed. The pinned stand commit is the spec version.
- Do not run stage: no stage CLI, API, deploy, dump, or port-forward. A live check uses the local stand.
- TDD: failing test, then the smallest implementation or `go generate`, then green.
- One binary. Public commands use the public client. Internal commands use the client under `int/`, not a directory named `internal` (that name is a Go visibility boundary). The two generated clients stay separate. Shared config, presenters, and HTTP error decode stay in `common`.
- A fail-fast constraint already in the accepted `endpoints/<slug>.md` stays fail-fast until that spec says to close it.
- Do not cite deleted docs from user-facing errors.
- Do not print tokens, secret keys, or passwords.

## Idioms

Published guides, not a local style invention: [Code Review Comments](https://go.dev/wiki/CodeReviewComments), [Test Comments](https://go.dev/wiki/TestComments), [Race Detector](https://go.dev/blog/race-detector), [Fuzzing](https://go.dev/security/fuzz/), [govulncheck](https://go.dev/blog/govulncheck), [staticcheck](https://staticcheck.dev/).

- Wrap errors with `%w`. Return errors. No panic on user or network input.
- Pass `context.Context` on outbound HTTP and cancellable work.
- Cobra adapters stay thin. HTTP shapes sit behind the generated client and a small facade.
- PATCH bodies use pointers and presence from `Flags().Changed`, including `false` and `0`.

## Workflow

1. When gopls is reachable, `blast_radius` on the symbol before the edit, diagnostics after.
2. RED. Acceptance tests live under `cmd/<binary>`.
3. Implement the minimum, or `make generate-openapi` for a contract change. Never hand-patch generated sources.
4. GREEN. `make test`.
5. Diagnostics again when gopls is reachable.

A live check uses `make local-up`, then `CLI_CONFIG=.local/cli.yaml bin/<binary> ...`. Agents do not run `make local-down`. It deletes stand data. A human runs it after the check.

## Go gates

Q1–Q4 are not defined in this skill; do not invent them. Any failure of an offline gate blocks the candidate. `make test` is the entry point.

### Offline

Run these before a candidate. They do not need the stand.

| Gate | Expectation |
|------|-------------|
| `gofmt` | `gofmt -l` empty on touched packages |
| `go vet ./...` | Clean |
| `staticcheck` | Pinned version, clean on handwritten packages |
| `make test` | `go test ./...` passes |
| `go test -race ./...` | Required where cgo and the race detector are available |
| `govulncheck ./...` | Pinned version, no unfixed vulns in dependencies |
| LSP | No new diagnostics when gopls is reachable |
| Plane split | Public commands use the public client, internal commands use the `int` client |

### Needs a stand

| Gate | Expectation |
|------|-------------|
| `make generate-openapi` | Regenerates clients from the stand's runtime spec |
| `make verify-openapi` | Empty diff against the committed clients |

When the stand is down, these two are `unknown`, not a skip and not a pass.

If the Makefile has `test` or `lint`, use that target. `golangci-lint run` only when the repository already has its config. Coverage is reported. There is no percentage threshold. Behavior and contract tests are the bar.

## Fuzz

Add a fuzz target when a parser, flag set, or presenter changes. The seed corpus runs under normal `go test`. A short `-fuzztime` (default 5s via `FUZZTIME`) when the fuzz target itself changes.

## Out of scope

Editing the service tree. Running stage e2e. Dependency bumps in the service repository.
