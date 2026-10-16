# Scripts

Agents run Makefile targets. They do not assemble the same steps by hand and they do not call `pytest` or `go test` when a target already wraps that command.

`script/` is the harness inside the CLI project, singular: `script/checks/validate-result.sh` is the only writer of status `succeeded`; `script/harness/new-worktree.sh` is the only worktree creator. This skill does not ship either file. `scripts/` is the CLI project's own helpers, plural, called by the Makefile: `scripts/make_docs.go`, `scripts/local-up.sh`, `scripts/local-down.sh`, `scripts/fetch-openapi.sh`.

## Offline

| Target | What it runs |
|--------|----------------|
| `make build` | `go build` into `bin/<binary>`. Version from `git describe`, injected with `-ldflags`. |
| `make test` | `go test ./...` |
| `make doc` | `go run ./scripts/make_docs.go`. Regenerates the Cobra reference under `docs/markdown/`. |
| `make e2e-unit` | Python 3.12 venv via `uv`, then `pytest -m unit`. |
| `make validate` | `script/checks/validate-result.sh`. The only writer of status `succeeded`. A `make test` pass is not that status. This skill does not ship the script. If it is absent, the check stays `unknown`. |

## Needs a stand

| Target | What it runs |
|--------|----------------|
| `make local-up` | `bash scripts/local-up.sh`. Local stand from the pinned service tree. Writes `.local/cli.yaml`. |
| `make fetch-openapi` | `bash scripts/fetch-openapi.sh`. Downloads the runtime spec into `openapi/.cache/`. Those files are not committed. |
| `make generate-openapi` | `fetch-openapi`, then `go generate ./openapi`. |
| `make verify-openapi` | Regenerates into a temp dir and diffs against the committed clients. A diff fails the target. |
| `make local-test` | Preflight, `make build`, then `pytest -m local`. |

If localhost is unreachable, set the network variable the project's fetch script documents. The public and internal spec paths are whatever that script fetches. When the stand is down, `make verify-openapi` is `unknown`, not a skip and not a pass.

## Agents do not run

`make local-down` (`bash scripts/local-down.sh`) deletes stand data, including the config. A human runs it after the check.

`make clean` deletes build output. Do not run it. Do not run a stage target.

A live CLI call after `make local-up`:

```text
CLI_CONFIG=.local/cli.yaml bin/<binary> ...
```

Agents do not run `make local-down`. It deletes stand data. A human runs it after the check.
