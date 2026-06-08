# Changes

## 2026-06-08

- Made `parse.py` importable under Python 3 while preserving the callback API.
- Added fake-workbook unit tests for type conversion, header skipping, missing
  cells, completion callbacks, and row-level exception callbacks.
- Opened workbooks on demand and released workbook resources after processing.
- Added a repeatable `make check` baseline for parser maintenance.
- Documented the `xlrd` 2.x `.xls` dependency boundary, unsupported date
  conversion, and synthetic fixture expectations.
