# Changes

## 2026-06-09

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
