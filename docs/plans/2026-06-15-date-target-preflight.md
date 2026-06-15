---
title: Date Target Preflight
type: reliability
status: completed
date: 2026-06-15
execution: code
---

# Date Target Preflight

## Problem Frame

Date conversion is explicitly unsupported, but `validate_cell_types()` includes
`CELL_DATE` in its accepted schema constants. A caller can therefore pass a
known-unsupported target, open a workbook, and receive repeated row-level
errors instead of one deterministic preflight failure.

## Scope Boundaries

- Reject `CELL_DATE` target schemas before `xlrd.open_workbook()`.
- Preserve the public `CELL_DATE` constant and public callback/process
  signatures for compatibility.
- Preserve rejection of source date cells and direct date conversion attempts.
- Do not implement date conversion, `.xlsx` support, workbook format changes,
  dependency changes, or callback lifecycle changes.
- Do not merge or close stacked pull requests without explicit authorization.

## Requirements

1. Distinguish declared cell constants from actually supported target types.
2. Raise `InvalidDataException` with a stable date-target message before any
   workbook access when `cell_types` contains `CELL_DATE`.
3. Preserve invalid-type, boolean, float-alias, schema-budget, and iterable
   normalization behavior.
4. Add focused tests for single and mixed date target schemas plus the existing
   direct/source date conversion boundary.
5. Update static contracts and project guidance with completed mutation and
   verification evidence.

## Verification Plan

- Add the focused preflight tests first and prove they fail on the current
  schema validator.
- Run the full Python 3.10-compatible local package gate, real synthetic `.xls`
  integration test, Ruff, compile, and dependency audit.
- Run the package gate from an external working directory.
- Reject hostile mutations for supported-type separation, both preflight tests,
  workbook ordering, error text, documentation, and completed-plan status.
- Audit generated artifacts, secrets, exact intended paths, and dependency or
  workflow drift before committing.

## Work Completed

- Added `SUPPORTED_TARGET_CELL_TYPES` while preserving the existing public
  constants and `VALID_CELL_TYPES` declaration set.
- Rejected date-only and mixed date target schemas with a stable
  `InvalidDataException` before `xlrd.open_workbook()`.
- Preserved direct target/source date conversion rejection and all callback and
  process signatures.
- Added focused regressions, static contracts, and synchronized project
  guidance.

## Verification Completed

- Root and external-directory `make check` passed all 38 unit and real `.xls`
  integration tests, Ruff checks, source compilation, and dependency audit.
- The dependency audit reported no known vulnerabilities.
- Eight isolated hostile mutations were rejected for supported-target
  separation, the date guard, both focused regressions, stable error text,
  pre-open ordering, documentation, and reopened plan status.
- Shell syntax, `git diff --check`, exact-path review, generated-artifact and
  secret-pattern audits, and staged-path review passed before delivery.
