---
title: Workbook Release Before Completion Callback
type: reliability
date: 2026-06-13
status: planned
execution: code
---

# Workbook Release Before Completion Callback

## Summary

Release the on-demand `xlrd` workbook before invoking the parse-completion
callback so “done” means row processing and workbook cleanup have both
completed.

## Requirements

- R1. Keep workbook cleanup in a `finally` block covering sheet lookup and row
  processing.
- R2. Invoke `parsedonecallback` only after successful resource release.
- R3. Ensure resources are already released when the completion callback runs
  or raises.
- R4. Preserve row indexes, conversions, exception-callback continuation,
  unhandled-row failure behavior, and public callback signatures.
- R5. Add focused ordering regressions and a mutation-sensitive static
  contract.

## Verification Plan

- Run focused tests for release-before-completion and completion-callback
  failure cleanup.
- Run the full unit and generated real `.xls` integration suite on Python 3.12
  and Python 3.14.
- Reject hostile mutations that restore completion-before-release, remove the
  regressions, or weaken completed plan evidence.
- Run the full `make check` dependency and compilation gate without private
  workbook data.

## Non-Goals

- Changing callback signatures, row conversion behavior, or `.xls` scope.
- Calling the completion callback after an unhandled processing failure.
- Adding `.xlsx` support or changing dependencies.
