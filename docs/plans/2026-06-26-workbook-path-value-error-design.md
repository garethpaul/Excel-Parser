# Workbook Path ValueError Design

status: completed

## Problem

Workbook path validation converts filesystem access failures into
`InvalidDataException`, but it catches only `OSError`. Python raises
`ValueError` for malformed strings such as paths containing an embedded NUL, so
those inputs escape the parser's public validation boundary before `xlrd` is
called.

## Evidence

- `validate_workbook_path` accepts any non-empty string ending in `.xls` before
  calling `os.stat`.
- `os.stat("fixture\0.xls")` raises `ValueError: embedded null byte`.
- The workbook path contract otherwise reports inaccessible or malformed paths
  through `InvalidDataException` before workbook access.

## Options Considered

1. Reject only the NUL character before `os.stat`. This duplicates one
   platform-specific failure and leaves other path-shape `ValueError` cases raw.
2. Catch every exception from `os.stat`. This would hide programming errors and
   unrelated failures too broadly.
3. Catch `ValueError` alongside `OSError` and map both documented path failures
   to the existing inaccessible-regular-file error.

## Decision

Use option 3. Preserve the current validation order, message, exception type,
and no-workbook-access guarantee while containing malformed path strings at the
filesystem boundary.

## Validation

- Add a focused process regression for an embedded-NUL `.xls` path.
- Require `InvalidDataException` and prove `xlrd.open_workbook` is not called.
- Add a hostile mutation that removes `ValueError` from the catch tuple.
- Run Python 3.10/3.12/3.14 matrices, full and external Make, audit, hosted
  checks, and CodeQL.

## Verification Completed

- Before implementation, `fixture\0.xls` raised raw
  `ValueError: embedded null byte` before workbook access.
- Focused and full tests pass with 49 tests.
- Python 3.12 and 3.14 `make check` pass with zero known vulnerabilities;
  external Make passes on Python 3.14.
- Python 3.10 compilation, tests, and static contracts pass; the embedded-NUL workbook path hostile mutation rejected the regression. Local audit scratch
  setup is blocked by unavailable `ensurepip` and awaits hosted verification.
- Hosted checks, CodeQL, exact-head review, and merge verification are pending.
