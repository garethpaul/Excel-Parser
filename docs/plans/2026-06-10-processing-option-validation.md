# Excel Processing Option Validation

## Status: Completed

## Goal

Reject ambiguous parser control values before opening workbook resources.

## Changes

- Require target cell types to be integer constants from `VALID_CELL_TYPES` and
  explicitly reject booleans and numerically equal floats.
- Keep Python 2 compatibility by recognizing both `int` and `long` while using
  `int` alone on Python 3.
- Require the sheet name to be a non-empty string.
- Require `has_header` to be an actual boolean rather than accepting arbitrary
  truthy values that can silently skip the first worksheet row.
- Add synthetic tests proving every invalid option fails before the fake `xlrd`
  implementation records a workbook open.
- Preserve these contracts in the maintenance baseline and project docs.

## Verification

- `make check`
- `python3 -m unittest discover -s tests -p "test*.py"`
- Python 2.7 `py_compile` of `parse.py` in an isolated container.
- `git diff --check`
- Mutations restoring equality-only cell-type validation, truthy header
  handling, and unchecked sheet names fail the corresponding regressions.
