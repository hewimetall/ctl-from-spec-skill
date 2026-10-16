# Endpoint table

`superpowers` is the Claude Code skill pack [obra/superpowers](https://github.com/obra/superpowers). Subagent-driven-development in that pack stores the accepted spec under `docs/superpowers/specs/` before implementation starts. The directory name is that pack's namespace. It is not a property of the routes.

The output file is `docs/superpowers/specs/endpoints.md`. A `base` line, then one table. No other prose in that file.

## Base

The first line is `base: <path>` or `base:` when the process serves the table at the host root.

- Django: `FORCE_SCRIPT_NAME`. Absent means empty.
- FastAPI: the `root_path` the process manager passes to the app. Absent means empty.
- OpenAPI: the path part of `servers[].url`. A host is not a base. Several servers with different paths stay as several `base:` lines, each with `server: <url>`. Workers do not start until one base is accepted. An unpicked server is `unknown`, not a guessed host.

`path` in the table is the resolved route only. The CLI joins `base` and `path`.

## Columns

| method | path | handler | file |

- `method` is one uppercase verb. One row per verb. `GET` and `DELETE` on the same path are two rows.
- `path` is the resolved path. Converters stay as declared (`{id}`, `{id:int}`, `{path:path}`).
- `handler` is the view callable, the endpoint function name, or the OpenAPI `operationId`.
- `file` is where the route is declared, relative to the project root, with `:line` when the line is known.

`any` is a row only when the declaration does not name a verb. Research may split it into one file per verb it can show. It does not overwrite a single file with one of those verbs.

## Slug

`docs/superpowers/specs/endpoints/<slug>.md`

`slug` is the method, a hyphen, then the path. Lowercase. Drop a leading slash. Replace `/`, `{`, `}`, `:`, and `.` with `-`. Collapse repeated hyphens and trim them.

`GET /v1/users/{id}` is `get-v1-users-id`. `DELETE /v1/users/{id}` is `delete-v1-users-id`. A row with method `any` keeps `any` in the slug.

## Where the verb is written

On this pass, do not open a function body, a pydantic model, or a `Depends` callable.

The verb is on the declaration:

- A FastAPI decorator (`get`, `post`, `put`, `patch`, `delete`, `head`, `options`) or the `methods=` argument of `add_api_route` / `add_route`.
- Django: `@api_view`, `http_method_names` on the class statement, a viewset action registered on a router, `@action(methods=...)`. The class statement and the decorator are the declaration.
- OpenAPI: the operation's method key.

If none of these name a verb, the row is `any`.

## blast_radius

Research reads one symbol: the handler. For FastAPI that includes the `Depends` and models named on its signature. Nothing else.

When a language server is running, that read is `blast_radius` on this symbol. `scope=all` means every reference kind of that symbol, not every file in the repository.

When no language server is running, read the handler's own file: decorators, class attributes, and signature annotations. Do not search the rest of the tree. What that read does not show is `unknown`, not a constraint. The research file is still written.

## Research file

```text
method:
path:
handler:
gap:
constraints:
```

`gap` is what the current code does not provide for this row. `constraints` are rules the current code already enforces. Cite the file for each one. A guess is `unknown`, not a constraint.

Workers start only after `endpoints.md` and every `endpoints/<slug>.md` are accepted. The judge's rubric is [judges.md](judges.md).
