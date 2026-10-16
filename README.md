# ctl-from-spec-skill

Skill that builds a CLI for a service. The service API is the contract. The CLI is the only code the run writes.

The API is one of:

- an OpenAPI file already on the table
- Django routes from `ROOT_URLCONF`
- a FastAPI app or `create_app()` factory, the object the process manager runs

The service repository that owns the API is not edited. Public and internal clients stay in separate directories. The internal client directory is `int`, not `internal`, because that name is a Go visibility boundary. Generated files marked `Code generated ... DO NOT EDIT` are regenerated, not edited by hand.

## Run

```text
ask → endpoints → research → accept spec → plan
  → fan-out: batch of 20 SWE (RED then GREEN)
  → fan-in: reports to the manager, then the user
  → delegated review
  → final review of the CLI against the accepted spec
```

1. Name the service tree and how its API is known. Do not edit code yet.
2. Write only the route table to `docs/superpowers/specs/endpoints.md`. `superpowers` is the namespace of the Claude Code skill pack [obra/superpowers](https://github.com/obra/superpowers): that is where its subagent-driven-development skill puts an accepted spec. The name does not describe the routes. One column scheme, a `base` line, and a slug that includes the method.
3. One research pass per row. Each file `docs/superpowers/specs/endpoints/<slug>.md` has `gap` and `constraints`. No language server does not skip the row.
4. Accept that set. No worker writes CLI code before it is accepted.
5. Plan the tasks that close the gaps the spec names.
6. The manager does not implement. Fan-out is a batch of 20 SWE in parallel, one task each. Fan-in returns the reports to the manager, who tells the user and delegates the next batch. Inside a task, TDD: a failing test, then the smallest change that passes. A Go change reads the Go skills below before the first edit.
7. The manager delegates the judge. The judge reads the diff against the accepted spec. The SWE does not judge its own task.
8. After the last task, one review of the whole CLI. Every listed route is implemented or named as skipped. The CLI has no route absent from the table.

Chat is not the record. The record is the plan and `docs/runtime/manifest.jsonl`.

The process that loaded this skill is the manager. It only delegates and talks to the user. It never walks routes, writes the CLI, runs tests, or reviews a diff. SWE launch as a batch of 20. Two SWE in that batch do not edit the same file. A Critical review issue is fixed by a new SWE before the next fan-out.

One SWE, one branch `agent/<run>/<role>/<task>`, one worktree `br/<run-id>/<worker-id>/`. SWE do not launch agents. `git push` is not part of the run. Agents do not run stage.

## Go

Handwritten tests are Arrange, one Act, Assert, standard `testing` only. A table is only for cases that share one act. Fakes are handwritten. Fuzz is a seed plus an invariant, without AAA comments. Details: [references/go-testing.md](references/go-testing.md).

Before a Go edit, the Q5 gates apply: `gofmt`, `go vet`, pinned `staticcheck`, `make test`, `go test -race` where cgo exists, pinned `govulncheck`, `make verify-openapi`, gopls diagnostics, and the split between the public client and the `int` client. A fail-fast constraint already written in `endpoints/<slug>.md` stays fail-fast until that spec says to close it. Details: [references/go-quality.md](references/go-quality.md).

## Scripts

Agents run Makefile targets, not the same commands assembled by hand.

| Target | Role |
|--------|------|
| `make build` | Binary in `bin/` |
| `make test` | `go test ./...` |
| `make doc` | Cobra reference via `scripts/make_docs.go` |
| `make local-up` / `make local-down` | Local stand. `local-down` deletes stand data |
| `make fetch-openapi` | Runtime spec into `openapi/.cache/`, not committed |
| `make generate-openapi` / `make verify-openapi` | Regenerate clients, then fail on drift |
| `make e2e-unit` | Offline Python tests |
| `make local-test` | Built binary against the local stand |

`make generate-openapi` and `make verify-openapi` need the stand up. Do not run `make clean`. Details: [references/scripts.md](references/scripts.md).

## Python e2e

`e2e/` is a Python 3.12 pytest harness. It starts the built binary with `subprocess` and no shell. `uv` installs the interpreter into `e2e/.venv`.

`make e2e-unit` runs marker `unit` with no network. `make local-test` preflights image, URL, and token, builds the binary, and runs marker `local` against loopback only. The token sits in a temporary config, mode `0600`, and is not logged. Mutation cases run only when the local mutation flag is set. Agents do not run stage suites. Details: [references/e2e-python.md](references/e2e-python.md).

## Layout

```text
SKILL.md
references/tdd.md               RED / GREEN / REFACTOR inside one task
references/sdd.md               manager delegates; SWE fan-out is a batch of 20
references/go-testing.md        Arrange, one Act, Assert
references/go-quality.md        Q5 gates and OpenAPI regenerate
references/scripts.md           Makefile targets and scripts/
references/e2e-python.md        pytest harness, offline and local
references/endpoints.md          one table, base, slug, blast_radius fallback
references/judges.md            rubric for the CLI diff
references/django-endpoints.md  root urls and DRF routers
references/fastapi-endpoints.md root app, resolved prefixes, mount fork
references/openapi-endpoints.md operations from the named document
```

`SKILL.md` is the procedure. The reference files are read when that step starts.
