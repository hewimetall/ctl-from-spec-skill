# FastAPI endpoints, then research

Use this only when the project is FastAPI: `fastapi` in the dependency file and a `FastAPI(` instance or a
`create_app()` factory. An app mounted on top of Django or Flask is not this case.

## 1. Root app

Find the object every `uvicorn`/`gunicorn` target points at. The string in the process manager, the Dockerfile `CMD`,
or `pyproject`/`Procfile` names it directly (`module:app`, `module:create_app()`). Read that module first. Do not start
from a router file that merely looks central.

## 2. Prefix resolution

Walk only router and app wiring:

- `include_router(router, prefix=...)`
- `APIRouter(prefix=..., dependencies=...)`
- `app.mount(...)` only when the mounted object is a FastAPI app or an APIRouter
- `add_api_route` / `add_route` calls that bypass decorators

`mount` of `StaticFiles`, or of a Django or Flask app through `WSGIMiddleware` or `ASGIMiddleware`, is not a prefix and not a row. That mounted app is out of scope for this table.

Concatenate prefixes down the tree. A route declared with `@router.get("/{id}")` inside a router with `prefix="/users"`
included at `prefix="/v1"` is one row: `GET /v1/users/{id}`. Path converters (`{id:int}`, `{path:path}`) keep their
declared form in the table.

The verb is the decorator (`get`, `post`, ...) or the `methods=` argument on `add_api_route` / `add_route`. One verb, one row. The decorated function body, the pydantic models, and the `Depends` callables stay closed on this pass.

## 3. What may be skipped

- Routers not reachable from the root app.
- `include_in_schema=False` is still a live endpoint — it belongs in the table.
- Websockets, `on_event`/`lifespan` hooks, middleware: out of scope for this table.

## 4. Output

The table, the `base` line, and the slug follow [endpoints.md](endpoints.md). `handler` is the function name. `file` is where the decorator or `add_api_route` call sits (`app/api/users.py:42`). The `base` line is the app `root_path`, or empty. Resolved paths only.

## 5. Research, one row at a time

When the table is complete, each row gets its own pass. The file shape and `blast_radius` are in [endpoints.md](endpoints.md). A missing language server does not stop the row.

- `gap` — what the tree does not have today at this route.
- `constraints` — what the current code already commits to: response shape, status codes, auth dependency, DB reads.

Until that set is accepted as the spec, no worker writes client code. Judges use [judges.md](judges.md).
