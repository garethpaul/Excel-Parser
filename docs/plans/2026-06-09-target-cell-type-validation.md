# Target Cell Type Validation

status: completed

## Context

`ExcelProcessor.process()` accepted `cell_types` and opened a workbook before
discovering invalid target type declarations during row conversion. Bad output
schemas should fail before workbook file resources are opened.

## Objectives

- Preserve the existing callback-driven processing API.
- Treat `None` `cell_types` as an empty target list.
- Reject non-iterable or unknown target cell type declarations before opening a
  workbook.
- Add fake-workbook coverage proving invalid declarations do not call
  `xlrd.open_workbook`.
- Extend docs and the static baseline so the guard remains visible.

## Work Completed

- Added `VALID_CELL_TYPES` and `validate_cell_types()` to normalize and validate
  target declarations up front.
- Made `process()` validate `cell_types` before opening workbooks.
- Added a unit test that verifies invalid target declarations fail before
  fake-workbook open calls.
- Updated README, SECURITY, VISION, CHANGES, and the baseline checker.

## Verification

- `sh -n scripts/check-baseline.sh`
- `scripts/check-baseline.sh`
- `python3 -m unittest discover -s tests -p "test*.py"`
- `make build`
- `make check`
- `git diff --check`
