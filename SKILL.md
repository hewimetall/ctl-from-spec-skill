---
name: ctl-from-spec
description: Builds a CLI for a service from its API. Use when the user asks for a command-line client for a service, names Django (ROOT_URLCONF) or FastAPI (FastAPI( / create_app), or puts an OpenAPI spec on the table.
---

# ctl-from-spec

This skill builds a CLI for a service. The service API is the contract. The CLI is the only code this run writes.

The service repository that owns the API is not edited. Public and internal clients stay in separate directories. The internal client directory is not named `internal`. Generated files whose first line matches `^// Code generated .* DO NOT EDIT\.$` are regenerated, not edited by hand.

A spec in `docs/superpowers/specs/` is accepted before any worker writes CLI code. `superpowers` is the Claude Code skill pack [obra/superpowers](https://github.com/obra/superpowers). Its subagent-driven-development skill keeps an accepted spec in that directory before workers write code. The name is the pack's namespace. It does not describe the endpoints.

## Manager

The process that loaded this skill is the manager. It is the only voice to the user.

The manager does not do the work. It does not walk urls, read a handler, write the CLI, run tests, or review a diff. It delegates every one of those to a fresh agent and waits.

Fan-out: the manager starts a batch of 20 SWE agents in parallel. Each SWE gets one task, one worktree, and no other SWE's scratchpad. If fewer than 20 tasks are ready, the batch is those tasks. The manager does not start a 21st SWE in the same batch. The manager does not take a task itself because the batch is short.

Fan-in: the batch reports back to the manager. The manager reads the reports, tells the user what came back, and delegates the next batch. It does not finish a SWE task from the report.

Two SWE in one batch do not edit the same files. A task that shares a file with a running SWE waits for the next fan-out.

## Flow

```text
ask → endpoints → research → accept spec → plan
  → fan-out: batch of 20 SWE (RED then GREEN)
  → fan-in: reports to the manager, then the user
  → delegated review
  → final review of the CLI against the accepted spec
```

1. **ask.** The user names the service tree and how its API is known: an OpenAPI file, Django, or FastAPI. Record both in `docs/team/goal.md`. Do not edit code.
2. **endpoints.** Write only the route table to `docs/superpowers/specs/endpoints.md`. Columns, `base`, and slug are in [endpoints.md](references/endpoints.md). No handler bodies, no models, no gap.
3. **research.** One pass per row, against the code as it is now. The file is `docs/superpowers/specs/endpoints/<slug>.md`. Slug includes the method, so two verbs on one path are two files. Without a language server, the fallback in [endpoints.md](references/endpoints.md) still writes the file.
4. **accept.** That set is the spec. The harness stays stopped until it is accepted.
5. **plan.** Tasks that close the gaps the spec names. The manager delegates writing the plan. A missing decision is a `Ruling` line in `docs/runtime/manifest.jsonl`. The run does not stop to ask.
6. **implement.** Fan-out a batch of 20 SWE. One fresh SWE per task, on its own worktree. Inside the task, TDD. A Go change reads [go-quality.md](references/go-quality.md) and [go-testing.md](references/go-testing.md) first. Commands go through the Makefile in [scripts.md](references/scripts.md). Fan-in to the manager. Details: [sdd.md](references/sdd.md), [tdd.md](references/tdd.md).
7. **review.** The manager delegates the judge. The judge reads the diff against the accepted spec. The rubric is [judges.md](references/judges.md). The SWE does not judge its own task. The manager does not judge it either. The judge does not walk urls or routers again.
8. **check.** Status `succeeded` is written only by `script/checks/validate-result.sh` in the CLI project. This skill does not ship that script. A transition line in `docs/runtime/manifest.jsonl` is not `succeeded`. If the script is absent, the check stays `unknown` and nothing else writes `succeeded`.

Chat is not state. The plan file and `docs/runtime/manifest.jsonl` are the record. A session todo list is a view of that plan, not a second record.

## Where the API comes from

Django: root urls from `ROOT_URLCONF`, nested includes, and DRF routers included as `router.urls`. [django-endpoints.md](references/django-endpoints.md).

FastAPI: the object the process manager runs (`module:app` or `module:create_app()`). Prefixes are concatenated along `include_router`, not copied from the decorator. [fastapi-endpoints.md](references/fastapi-endpoints.md).

OpenAPI: the named document. Same table, same slug, `servers[].url` path as `base`. [openapi-endpoints.md](references/openapi-endpoints.md).

## CLI

One binary. Commands cover the accepted rows: implemented, or named as skipped. The client has no route that is absent from `endpoints.md`.

A constraint in `endpoints/<slug>.md` still holds in the diff. A gap is closed only when that row's spec told the worker to close it.

Handwritten Go is TDD plus the Q5 gates: `gofmt`, `go vet`, pinned `staticcheck`, `make test`, `go test -race` where cgo exists, pinned `govulncheck`, `make verify-openapi`, gopls diagnostics, and the public/`int` client split. Generated clients are regenerated with `make generate-openapi`.

Python e2e is a separate harness under `e2e/`. `make e2e-unit` is offline pytest. `make local-test` runs the built binary against the local stand. Agents do not run stage. [e2e-python.md](references/e2e-python.md).

Do not call a live stage. Do not print tokens, secret keys, or passwords. `git push` is not part of this run.

## Worktrees

One fresh SWE, one branch `agent/<run>/<role>/<task>`, one worktree `br/<run-id>/<worker-id>/`. SWE do not launch agents. Only the manager does. In the CLI project, `script/harness/new-worktree.sh` is the only creator. This skill does not ship that script. Base commit is an argument. `br/` is gitignored in the main checkout. If the script is absent, a worktree is not invented by hand.

Fan-out is 20 SWE in parallel. Fan-in returns their reports to the manager. The next batch starts only after that fan-in. Two SWE never edit the same files.

## References

- [sdd.md](references/sdd.md) — manager delegates; SWE fan-out is a batch of 20
- [tdd.md](references/tdd.md) — RED / GREEN / REFACTOR inside one task
- [go-testing.md](references/go-testing.md) — Arrange, one Act, Assert for handwritten Go
- [go-quality.md](references/go-quality.md) — Q5 gates, OpenAPI regenerate, local stand
- [scripts.md](references/scripts.md) — Makefile targets and `scripts/`
- [e2e-python.md](references/e2e-python.md) — pytest harness, offline unit and local stand
- [endpoints.md](references/endpoints.md) — one table, base, slug, blast_radius fallback
- [judges.md](references/judges.md) — the rubric for the CLI diff
- [django-endpoints.md](references/django-endpoints.md) — root urls and DRF routers
- [fastapi-endpoints.md](references/fastapi-endpoints.md) — root app, resolved prefixes, mount fork
- [openapi-endpoints.md](references/openapi-endpoints.md) — operations from the named document
