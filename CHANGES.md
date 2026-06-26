# Changes

## 2026-06-26 08:02 PDT

Priority: correctness and parser exception-boundary integrity.

Summary:

- Contained malformed workbook path strings inside the parser's documented
  `InvalidDataException` contract.

Work completed:

- Caught path-shape `ValueError` alongside filesystem `OSError` around
  `os.stat`.
- Added an embedded-NUL `.xls` regression that proves workbook access never
  begins.
- Added a hostile mutation, static contracts, guidance, and implementation plans.

Threads:

- Workbook preflight, malformed filesystem input, callback-facing exception
  consistency, and maintained verification.

Files changed:

- `parse.py`, `tests/test_parse.py`, mutation and baseline scripts, project
  guidance, and workbook-path plans.

Validation:

- Red phase: `fixture\0.xls` raised raw `ValueError: embedded null byte`.
- Green focused and full Python 3.12 tests pass with 49 tests.
- Python 3.12 and 3.14 `make check` pass with 49 tests, mutation rejection, and
  zero known audit vulnerabilities; external Make passes on Python 3.14.
- Python 3.10 passes compilation, all 49 tests, static contracts, and the hostile
  mutation. Its local `pip-audit` scratch environment is blocked by unavailable
  `ensurepip`; hosted Python 3.10 remains the authoritative full gate.
- Hosted checks, CodeQL, and review are pending.

Bugs and findings:

- The `.xls` suffix check allowed embedded-NUL strings to reach `os.stat`, whose
  `ValueError` bypassed the parser's public validation exception.
- Malformed workbook path strings, including embedded NUL values, fail through `InvalidDataException` before workbook access.

Blockers:

- None for local implementation.

Next action:

- Push the focused PR, then verify hosted Python 3.10/3.12/3.14 and CodeQL.

## 2026-06-19

- Required regular `.xls` files no larger than 64 MiB and bounded sheets and
  text cells to the legacy format's 65,536-row and 32,767-character limits.
- Stopped treating inconsistent `cell_value` failures as missing cells and
  rejected boolean aliases for source cell types.
- Preserved primary processing exceptions when workbook cleanup also fails and
  bounded multiline error summaries without copying full values.
- Added real-workbook coverage for formula cached-result and date rejection.

## 2026-06-15

- Unsupported date targets are rejected before workbook access.

## 2026-06-14

- Added pinned, least-privilege CodeQL analysis for GitHub Actions and Python
  to the hosted workflow.
- Limited target schemas to 256 target columns and bounded iterable
  normalization before workbook access.

## 2026-06-13

- Made Make verification independent of the caller's working directory.
- Required a callable workbook release hook before sheet access and completion
  signaling.
- Released workbook resources before invoking the parse-completion callback.
- Established Python 3.10 or newer as the maintained runtime and removed
  dormant `basestring`, `long`, old-style class, and Python 2 compile branches.
- Added a regression for the preserved `ExcelProcessor` constructor and
  `process` callback signatures.
- Validated parser callbacks before opening workbook files so invalid row,
  completion, and exception handlers fail through `InvalidDataException`.

## 2026-06-12

- Stopped GitHub Actions checkout credential persistence and added an exact
  contract for the single pinned checkout step.
- Added an end-to-end test that generates a temporary synthetic `.xls`
  workbook and processes it through the real `xlrd` boundary.
- Pinned the test-only `xlwt` writer and extended the maintenance baseline to
  preserve real workbook, callback-order, header, conversion, and missing-cell
  coverage.

## 2026-06-10

- Rejected boolean and floating-point aliases for target cell type constants.
- Required non-empty string sheet names and boolean header flags before opening
  workbook resources.
- Added fail-fast option validation tests and maintenance baseline contracts.
- Added a pinned, read-only GitHub Actions matrix that installs dependencies and
  runs `make check` on Python 3.10, 3.12, and 3.14.
- Pinned `xlrd` 2.0.2 and `pip-audit` 2.10.0, then added dependency auditing to
  the local and hosted verification gate.

## 2026-06-09

- Validated workbook paths as non-empty `.xls` paths before opening workbook
  files.
- Validated target cell type declarations before opening workbook files.
- Summarized long, multiline, or unprintable conversion error values before
  raising parser exceptions.
- Rejected non-string text cell values through `InvalidDataException` and
  exposed `make lint`, `make test`, and `make build` gates.
- Rejected non-finite numeric cells even when callers request text output.
- Rejected non-finite numeric conversions such as `nan` and `inf`.
- Routed text-to-number conversion failures through `InvalidDataException` for
  blank and malformed text cells.
- Added unit and baseline coverage for invalid text integer/float conversion.

## 2026-06-08

- Rejected fractional numeric cells when callers request integer conversion.
- Made `ExcelProcessor.CELL_EMPTY` an explicit target type for skipped output
  columns.
- Made `parse.py` importable under Python 3 while preserving the callback API.
- Added fake-workbook unit tests for type conversion, header skipping, missing
  cells, completion callbacks, and row-level exception callbacks.
- Opened workbooks on demand and released workbook resources after processing.
- Added a repeatable `make check` baseline for parser maintenance.
- Documented the `xlrd` 2.x `.xls` dependency boundary, unsupported date
  conversion, and synthetic fixture expectations.
