# Scripts

Agents run Makefile targets. They do not assemble the same steps by hand and they do not call `pytest` or `go test` when a target already wraps that command.

| Target | What it runs |
|--------|----------------|
| `make build` | `go build` into `bin/<binary>`. Version from `git describe`, injected with `-ldflags`. |
| `make test` | `go test ./...` |
| `make doc` | `go run ./scripts/make_docs.go`. Regenerates the Cobra reference under `docs/markdown/`. |
| `make local-up` | `bash scripts/local-up.sh`. Local stand from the pinned service tree. Writes `.local/cli.yaml`. |
| `make local-down` | `bash scripts/local-down.sh`. Stops the stand and deletes its data, including the config. |
| `make fetch-openapi` | `bash scripts/fetch-openapi.sh`. Downloads runtime `/openapi.json` into `openapi/.cache/`. Those files are not committed. |
| `make generate-openapi` | `fetch-openapi`, then `go generate ./openapi`. |
| `make verify-openapi` | Regenerates into a temp dir and diffs against the committed clients. A diff fails the target. |
| `make e2e-unit` | Python 3.12 venv via `uv`, then `pytest -m unit`. |
| `make local-test` | Preflight, `make build`, then `pytest -m local`. |

`generate-openapi` and `verify-openapi` need a running stand. If localhost is unreachable, set the network variable the project's fetch script documents. The public and internal spec paths are whatever that script fetches.

Do not run `make clean`. Do not run a stage target.

A live CLI call after `make local-up`:

```text
CLI_CONFIG=.local/cli.yaml bin/<binary> ...
```

`make local-down` when the check is finished.
