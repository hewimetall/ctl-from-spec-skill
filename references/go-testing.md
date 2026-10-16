---
name: go-testing
description: >-
  Write and review handwritten Go tests for the CLI with Arrange-Act-Assert,
  the standard testing package, table-driven subtests, and handwritten fakes.
  Use when adding, cleaning, or reviewing *_test.go. Do not use for fuzz-only
  edits or for generated code.
---

# Go tests (AAA)

Tests are executable specs. One `Test*` is one promise about behavior. Inputs
are cases inside that promise. A name that reads as a function (`TestParseID`)
is too big. The name is `Test<Subject>_<Behavior>`.

Standard `testing` only: no testify, gomock, or snapshots.

Sources: [Test Comments](https://go.dev/wiki/TestComments),
[TableDrivenTests](https://go.dev/wiki/TableDrivenTests),
[subtests](https://go.dev/blog/subtests).

Read the Go version from `go.mod`. Do not call an API newer than that version.
`t.Context` and `b.Loop` need Go 1.24. `testing/synctest` needs Go 1.25.
Since Go 1.22 the loop variable is per iteration. Do not copy `tt := tt` into
a new test unless `go.mod` is below 1.22.

## Shape

Every `Test*` and every `t.Run` body is three sections, in this order, with a
blank line between them:

```go
func TestParseID_rejectsName(t *testing.T) {
	t.Parallel()

	// Arrange
	in := "name"

	// Act
	_, err := ParseID(in)

	// Assert
	if !errors.Is(err, ErrIDRejected) {
		t.Fatalf("ParseID(%q) returned %v, want %v", in, err, ErrIDRejected)
	}
}
```

- Arrange builds inputs, fakes, and flags. It does not call the function under test.
- Act is one call.
- Assert checks the one field the promise is about. Known errors use `errors.Is` or `errors.As`. Do not compare a whole struct with `reflect.DeepEqual`. Failure text is a sentence that includes got and want: `t.Fatalf("ParseID(%q) returned %q, want %q", in, got, want)`.
- Helpers take `t *testing.T`, call `t.Helper()`, and do not hide the act. A repeated Assert is `assertX(t, got, want)` that calls `t.Helper()`.
- Files use `t.TempDir()`. Helpers use `t.Cleanup`, not `defer`.
- `t.Parallel` only when the test has no shared state and does not call `t.Setenv`.

Group tests in the file by the symbol they cover, in the same order as the
code. Each behavior of that symbol stays its own `Test*`.

Use a table only when every case performs the same act and asserts the same
kind of outcome. Success cases go in one table. Each error class gets its own.
A flag's effect gets its own. Two want fields such as `wantErr` and `wantID`
in one table means two tests. Put Arrange / Act / Assert inside the subtest.

One assertion target per subtest. A subtest that checks both an error and a
value is two tests wearing one name.

Subtest names are short lowercase phrases: `name_is_rejected`,
`empty_flag_defaults_to_current`. The name plus the failure line must explain
the broken promise without opening the source.

```go
func TestParseID_rejectsEmpty(t *testing.T) {
	t.Parallel()

	cases := map[string]struct {
		in   string
		want error
	}{
		"empty_is_rejected": {in: "", want: ErrIDRequired},
		"blank_is_rejected": {in: "   ", want: ErrIDRequired},
	}

	for name, tc := range cases {
		t.Run(name, func(t *testing.T) {
			t.Parallel()

			// Arrange
			in := tc.in

			// Act
			_, err := ParseID(in)

			// Assert
			if !errors.Is(err, tc.want) {
				t.Fatalf("ParseID(%q) returned %v, want %v", in, err, tc.want)
			}
		})
	}
}
```

A returned id is a separate promise. Assert that field alone. A nil error is its own `Test*`.

```go
func TestParseID_returnsID(t *testing.T) {
	t.Parallel()

	// Arrange
	in := "ok"

	// Act
	got, _ := ParseID(in)

	// Assert
	assertID(t, got, "id-1")
}

func assertID(t *testing.T, got, want string) {
	t.Helper()
	if got != want {
		t.Fatalf("the id is %q, want %q", got, want)
	}
}
```

## What not to write

- A second act in the same test. Split it.
- Assertions mixed into setup.
- `strings.Contains` on an error that already has a sentinel.
- Copied command-tree walkers. Share one helper in the test file.
- Coverage padding, commented-out cases, and tests that only check a type exists.
- AAA comments on fuzz targets. Fuzz stays a seed via `f.Add` plus an invariant in the loop. A crash kept in `testdata/fuzz` stays a regression.

## Split signals

A test is too big when any of these holds. Split it. Apply the list by
judgment. Do not turn it into a grep or a CI line cap.

- Two assertions on different objects in one body.
- The test name reads as a function (`TestParseID`). Use `Test<Subject>_<Behavior>`.
- A subtest name is not a phrase (`case1`, `ok`, `test2`).
- A subtest cannot run alone via `go test -run 'TestX/name'`.
- A table where most fields are zero for most cases.
- A `Test*` body with more than one call to the symbol under test.
- A test you cannot understand without reading Arrange.
- A `Test*` body of about 30 lines. That length is a judge signal, not a grep or a CI cap.

Splitting must not copy-paste. A repeated Arrange is a helper. A repeated
Assert is `assertX(t, got, want)` that calls `t.Helper()`. A repeated act with
different inputs is one table, not three tests.

## Fakes

Handwritten fakes implement the consumer interface. Record the call the act
made; assert that record after the act. Do not import the other API plane
from a test that belongs to one command family.

## Run

The repository test command is `make test` when that target exists. It runs
`go test ./...`. Add `go test -race` when the code under test starts goroutines.
`-race` needs cgo. `CGO_ENABLED=0` is `unknown`, not a skip.
