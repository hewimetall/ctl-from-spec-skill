# Python e2e

End-to-end checks are a Python 3.12 pytest harness. It starts the built binary with `subprocess` and no shell. Go unit tests do not replace this harness. The service's own pytest suite is not this harness.

Default command is `make e2e-unit`: offline tests, marker `unit`. No network.

Local acceptance is `make local-test`. It preflights the image, URL, and token, builds the binary, then runs `pytest -m local`. Loopback only: host is `localhost`, `127.0.0.1`, or `::1`. A missing local env skips a direct pytest run. An invalid or non-loopback URL is a hard refusal.

The token is written to a temporary config, mode `0600`. Tests and logs do not print it. Redaction runs before any captured output is kept.

Markers:

| Marker | When it runs |
|--------|----------------|
| `unit`, `offline` | No network. This is `make e2e-unit`. |
| `local` | Loopback stand. `make local-test`. |
| `local_readonly` | Health, version, config, read-only API. |
| `local_mutate` | Only with `CLI_E2E_LOCAL_ALLOW_MUTATIONS=1`. Without it, mutation cases skip. |

The harness uses `uv` so the host Python does not have to be 3.12:

```text
make e2e-unit
```

That target installs CPython 3.12 into `e2e/.venv` and runs `.venv/bin/pytest -m unit`. Dependencies are pytest and PyYAML, pinned in `e2e/pyproject.toml`. `requires-python` is `>=3.12,<3.13`.

Binary discovery, in order: an env path for the binary, then `bin/<name>` at the repo root. A missing binary skips that suite with an explicit reason.

Agents do not run stage. Stage targets, if a Makefile still has them, are for a human on a workstation and are not in CI. The agent run is offline unit plus the local stand.

`make local-test` does not start the stand. Bring the stand up with `make local-up` first. See [scripts.md](scripts.md).
