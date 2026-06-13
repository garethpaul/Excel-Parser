---
title: Excel Parser Callback Validation
type: reliability
status: in_progress
date: 2026-06-13
---

# Excel Parser Callback Validation

## Summary

Validate the parser's three callback slots before opening a workbook so invalid
handlers fail with `InvalidDataException` instead of surfacing delayed raw
`TypeError` exceptions during row delivery, error handling, or completion.

## Priority

1. Reject invalid callback configuration before workbook resources are touched.
2. Preserve the callback-driven public API and row-level recovery behavior.
3. Keep Python 2 syntax compatibility and the hosted Python 3 matrix intact.

## Requirements

- R1. `rowdatacallback` and `parsedonecallback` must be callable when processing
  begins.
- R2. `exceptioncallback` must be either `None` or callable.
- R3. Invalid callbacks must raise `InvalidDataException` before workbook path,
  sheet, or row processing opens a workbook.
- R4. Valid callbacks must retain existing row delivery, row-error recovery,
  completion ordering, and workbook resource release behavior.
- R5. Unit tests and the static baseline must reject removal or reordering of
  the fail-fast callback boundary.
- R6. The current checkout credential boundary from successor PR #3 must be
  integrated without altering its exact source commit or closing that PR.

## Non-Goals

- Changing callback signatures or return-value handling.
- Adding asynchronous processing, retries, or workbook format support.
- Converting the legacy callback API to iterators, generators, or coroutines.
- Merging or closing existing pull requests.

## Implementation Units

### 1. Callback Contract

Files: `parse.py`

- Add a focused validator for required and optional callback slots.
- Invoke it before workbook option validation and `xlrd.open_workbook`.
- Use stable errors that do not expose callback object representations.

### 2. Regression Coverage

Files: `tests/test_parse.py`, `scripts/check-baseline.sh`

- Cover each invalid callback slot and prove no workbook is opened.
- Preserve the successful callback and row-error recovery paths.
- Require the validator call to remain first in `process`.

### 3. Project Guidance

Files: `README.md`, `SECURITY.md`, `VISION.md`, `CHANGES.md`

- Document fail-fast callback configuration and verification evidence.

## Verification Plan

- Run the focused callback tests under the available Python runtime.
- Run `make check`, `make lint`, `make test`, and `make build`.
- Mutate away callback validation and reorder it after workbook validation; the
  static/test gate must reject both changes.
- Run `git diff --check` and an intended-file secret scan.
- Take one bounded exact-head hosted check snapshot after push; do not poll.
