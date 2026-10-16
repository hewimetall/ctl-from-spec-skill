# OpenAPI endpoints, then research

Use this when the API on the table is an OpenAPI document. Django urls and a FastAPI app are the other two sources. They are not read to invent operations the document does not list.

## 1. Document

The user named the file. Read that file. Do not pick a second spec because it looks more complete.

## 2. Rows

One operation is one row. The method is the operation key (`get`, `post`, ...). The path is the OpenAPI path, parameters kept as declared. `handler` is `operationId`. When `operationId` is missing, `handler` is `unknown` and the row still exists. `file` is the spec file and the line of that operation when the file has lines.

The path part of `servers[].url` is the `base` line from [endpoints.md](endpoints.md). A server url without a path is an empty base. Do not copy the host into the table.

`deprecated: true` stays in the table. It is a live operation until the spec drops it.

## 3. Output and research

The table, the slug, and the research file follow [endpoints.md](endpoints.md). There is no language-server pass over a spec file. `gap` and `constraints` come from the operation as written: parameters, request body, responses, security requirements. What the document does not say is `unknown`, not a constraint.

Do not open the service handler that might implement the operation on this pass. Mapping an `operationId` onto a symbol is the later research row, and only when the service tree is the tree under study. The service repository that owns the API is still not edited.

Until that set is accepted, no worker writes client code. Judges use [judges.md](judges.md).
