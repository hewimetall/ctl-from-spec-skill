# Django endpoints, then research

Use this only when the project is Django: `manage.py` plus `django` in the dependency file, or a settings module with `ROOT_URLCONF`.

## 1. Root urls

Read `ROOT_URLCONF` from the settings module the project actually loads. That module is the root. Do not guess a second urls file when this setting exists.

## 2. Nested walk

From the root, follow only url-related links:

- `path`, `re_path`, `url`
- `include` of another urls module
- list concatenation that builds `urlpatterns`
- `include` of a DRF `SimpleRouter` or `DefaultRouter` through `router.urls`

Open the included module and repeat. A router included this way is not an empty `urlpatterns`. Each `.register(prefix, viewset)` and each `@action` on that viewset is a route. The path is the include prefix, the register prefix, and the pattern that router assigns the action, including the router's trailing slash. Standard actions take their verb from the registration: `list` GET, `create` POST, `retrieve` GET, `update` PUT, `partial_update` PATCH, `destroy` DELETE. An `@action` takes `methods`. An action that is not registered is not a row.

Stop at a view callable: record its dotted name and file. Do not open the view body on this pass. Do not follow models, serializers, tasks, or templates.

## 3. Endpoints only

Write the table from [endpoints.md](endpoints.md). `handler` is the view callable. `file` is the urls module that declared the pattern, or the module that called `.register` / `@action`.

`path()` and `re_path()` do not name a verb. Take the verb from `@api_view`, from `http_method_names` on the class statement, or from the router action. That is the declaration. The function body stays closed. If none of these name a verb, the row is `any`.

The `base` line is `FORCE_SCRIPT_NAME`, or empty. No gap and no constraint in this file. Research waits until every nested urls module and every included router in the walk has been recorded.

## 4. Research, one endpoint at a time

After the table is complete, research each row separately. The file shape, the slug, and `blast_radius` are in [endpoints.md](endpoints.md). A missing language server does not stop the row: the fallback there still writes `gap` and `constraints`. A guess is `unknown`, not a constraint.

`constraints` for Django are the rules the current code already enforces (auth, lookup, status codes, required fields). Cite the file that shows each one.

Workers start only after this set is accepted. Judges use [judges.md](judges.md).
