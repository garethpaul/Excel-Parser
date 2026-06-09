---
title: Text Cell Value Validation
type: reliability
status: completed
date: 2026-06-09
---

# Text Cell Value Validation

## Summary

Reject non-string text cell values through `InvalidDataException` before text,
integer, or float conversion helpers can leak raw attribute errors.

## Requirements

- R1. Preserve existing whitespace trimming for valid text cells.
- R2. Reject non-string text cell values for `CELL_TEXT`, `CELL_INT`, and
  `CELL_FLOAT` targets.
- R3. Keep the behavior covered by offline unit tests.
- R4. Update README, VISION, CHANGES, SECURITY, and the baseline guard.
- R5. Expose `make lint`, `make test`, and `make build` gates.

## Verification

- `python3 -m unittest discover -s tests -p "test*.py"`
- `scripts/check-baseline.sh`
- `make lint`
- `make test`
- `make build`
- `make check`
- `git diff --check`
