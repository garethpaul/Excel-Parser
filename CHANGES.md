# Changes

## 2026-06-13

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
