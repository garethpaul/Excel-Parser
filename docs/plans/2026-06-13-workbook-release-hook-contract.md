---
title: Workbook Release Hook Contract
type: reliability
date: 2026-06-13
status: completed
execution: code
---

# Workbook Release Hook Contract

## Summary

Fail closed when an opened on-demand workbook cannot provide a callable
resource-release hook, so the parse-completion callback never reports cleanup
that did not occur.

## Requirements

- R1. Require a callable `release_resources` hook before sheet processing.
- R2. Do not invoke row or completion callbacks when the release contract is
  unavailable.
- R3. Preserve release-before-completion ordering for valid workbooks.
- R4. Preserve callback signatures, conversions, `.xls` scope, and dependency
  pins.
- R5. Add focused regressions and mutation-sensitive static contracts.

## Verification Plan

- Run focused missing and non-callable release-hook tests.
- Run the full unit and generated real `.xls` integration suite on Python 3.12
  and Python 3.14.
- Reject hostile mutations that restore optional cleanup, remove the focused
  regressions, or weaken completed plan evidence.
- Run shell syntax, diff, exact-path, secret, and generated-artifact checks.

## Non-Goals

- Changing callback signatures, row conversion behavior, or dependency pins.
- Adding `.xlsx` support or private workbook fixtures.

## Verification

- Python 3.12.8 and Python 3.14.0 each passed the four focused lifecycle tests
  and all 30 unit and generated real `.xls` integration tests.
- `make check` passed under both pinned environments, including compilation and
  dependency audits reporting no known vulnerabilities.
- Seven hostile mutations were rejected across callable-hook validation,
  optional cleanup, validation order, focused regressions, documentation, and
  completed plan evidence.
- Shell syntax, diff, exact-path, unchanged dependency/workflow, secret-like
  addition, and generated-artifact inspections passed.
- No private workbook data, external service, or live network request was used.
