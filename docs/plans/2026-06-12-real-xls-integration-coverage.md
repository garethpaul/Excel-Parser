# Real XLS Integration Coverage

## Status: Completed

## Goal

Prove that the documented `.xls` workflow works through the real `xlrd`
boundary instead of relying exclusively on fake workbook objects.

## Prioritized Engineering Work

1. **Exercise a synthetic real workbook in CI (this change).** Generate a
   temporary `.xls` file, process it through `ExcelProcessor`, and verify sheet
   selection, header skipping, text and numeric conversion, missing cells,
   row callbacks, and completion callbacks.
2. **Validate callback contracts before opening workbooks (follow-up).** Decide
   whether construction or processing should reject non-callable callbacks
   without changing the legacy callback API unexpectedly.
3. **Decide the Python 2 compatibility boundary (follow-up).** Either add a
   reproducible legacy syntax job or complete a documented Python 3-only
   migration instead of preserving an unverified compatibility claim.
4. **Decide whether `.xlsx` belongs in scope (follow-up).** Keep the current
   `.xls` boundary explicit until a separate format and migration decision is
   made.

## Requirements

- R1. The integration test must create only synthetic workbook data in a
  temporary directory and must not commit private or generated spreadsheet
  fixtures.
- R2. The test must use the installed `xlrd` implementation used in production,
  not the fake workbook adapter used by unit tests.
- R3. The workbook must include a header, text, integer-valued numeric,
  fractional numeric, and missing-cell cases.
- R4. Assertions must cover row indexes, normalized values, callback ordering,
  header skipping, and the single completion callback.
- R5. `xlwt` must be pinned as a development-only dependency and audited with
  the existing dependency gate.
- R6. Existing fake-workbook tests and the public parser API must remain
  unchanged.
- R7. The maintenance baseline and documentation must reject removal of the
  real-workbook integration contract.

## Verification

- `make check` in a clean environment with pinned dependencies.
- `python3 -m unittest discover -s tests -p "test*.py"`.
- GitHub Actions on Python 3.10, 3.12, and 3.14.
- `git diff --check`.
- Mutation check: replacing real `xlrd` with the fake adapter in the integration
  test must fail the integration assertions or explicit identity guard.

## Work Completed

- Added a dedicated integration test that writes a temporary synthetic `.xls`
  workbook with `xlwt` and processes it through the installed `xlrd` module.
- Covered header skipping, real text and numeric cell types, text-to-number
  conversion, a missing cell, row indexes, callback ordering, and the single
  completion callback.
- Pinned `xlwt==1.3.0` as a development-only dependency and included it in the
  existing `pip-audit` gate.
- Updated the build gate, maintenance baseline, project documentation, security
  posture, and roadmap without changing the parser API or runtime dependency.

## Verification Completed

- A clean Python 3.12 virtual environment passed `make check` with 22 tests.
- `python3 -m pip_audit -r requirements.txt -r requirements-dev.txt` reported
  no known vulnerabilities.
- GitHub Actions run `27391562146` passed on Python 3.10, 3.12, and 3.14.
- `git diff --check` passed.
- Replacing `parse.xlrd` with a different object made the integration test fail
  at `self.assertIs(parse.xlrd, xlrd)`, proving the real-module guard is active.
