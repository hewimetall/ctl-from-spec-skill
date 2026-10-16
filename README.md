# ctl-from-spec-skill

Skill that builds a CLI for a service. The service API is the contract. The CLI is the only code the run writes.

The API is an OpenAPI file already on the table, Django routes from `ROOT_URLCONF`, or a FastAPI app or `create_app()` factory. The service repository that owns the API is not edited.

The rules live in [SKILL.md](SKILL.md). `superpowers` is the namespace of the Claude Code skill pack [obra/superpowers](https://github.com/obra/superpowers); why the accepted spec sits under `docs/superpowers/specs/` is in SKILL.md.

## Files

- [references/tdd.md](references/tdd.md) — RED / GREEN / REFACTOR inside one task
- [references/sdd.md](references/sdd.md) — manager delegates; SWE fan-out is a batch of 20
- [references/go-testing.md](references/go-testing.md) — Arrange, one Act, Assert
- [references/go-quality.md](references/go-quality.md) — Go gates and OpenAPI regenerate
- [references/scripts.md](references/scripts.md) — Makefile targets, `script/`, and `scripts/`
- [references/e2e-python.md](references/e2e-python.md) — pytest harness, offline and local
- [references/endpoints.md](references/endpoints.md) — one table, base, slug, blast_radius fallback
- [references/judges.md](references/judges.md) — rubric for the CLI diff
- [references/django-endpoints.md](references/django-endpoints.md) — root urls and DRF routers
- [references/fastapi-endpoints.md](references/fastapi-endpoints.md) — root app, resolved prefixes, mount fork
- [references/openapi-endpoints.md](references/openapi-endpoints.md) — operations from the named document
