---
title: Text Number Conversion Errors
date: 2026-06-09
status: completed
execution: code
---

## Context

Text cells requested as integer or float targets were converted through raw
`int()` and `float()` calls. Blank text and malformed numeric text therefore
leaked Python `ValueError` exceptions instead of using the parser's
`InvalidDataException` error type.

## Goals

- Keep text-to-number conversion failures explicit and parser-owned.
- Reject blank text values before attempting integer or float conversion.
- Preserve successful stripped text-to-int and text-to-float conversions.
- Keep row-level exception callbacks receiving a parser exception for invalid
  spreadsheet data.

## Implementation

- Added `convert_text_to_int` and `convert_text_to_float`.
- Routed text-cell integer and float conversion through those helpers.
- Added unit tests for blank and malformed text numeric values.
- Updated the row-error callback test to expect `InvalidDataException`.
- Extended `scripts/check-baseline.sh` to preserve the helpers and tests.

## Verification

- `python3 -m unittest discover -s tests -p "test*.py"`
- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`

Python 2 syntax checks are skipped locally when `python2` is not installed.
