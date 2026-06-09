# Fractional Integer Conversion Guard

status: completed

## Context

`ExcelProcessor.convert_type` previously converted `XL_CELL_NUMBER` values to
`CELL_INT` with Python's `int(...)`, truncating fractional spreadsheet numbers
without surfacing data loss.

## Objectives

- Preserve integer-valued numeric cells such as `3.0` converting to `3`.
- Reject fractional numeric cells when callers request `CELL_INT`.
- Add offline unit coverage for the rejected fractional path.
- Keep README, VISION, CHANGES, and the baseline aligned with the conversion
  contract.

## Verification

- `make check`
- `python3 -m unittest discover -s tests -p "test*.py"`
- `git diff --check`
