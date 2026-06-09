---
title: Non-Finite Number Text Conversion
type: reliability
status: completed
date: 2026-06-09
---

# Non-Finite Number Text Conversion

## Summary

Reject non-finite Excel numeric cells even when callers request text output, so
`nan` and `inf` values cannot reach row callbacks as strings.

## Requirements

- R1. Preserve finite numeric-to-text conversion behavior.
- R2. Reuse the existing non-finite numeric validation path.
- R3. Add regression coverage for numeric cells requested as `CELL_TEXT`.
- R4. Update README, VISION, CHANGES, and the baseline guard.
- R5. Preserve the callback API and unsupported date conversion boundary.

## Verification

- `python3 -m unittest discover -s tests -p "test*.py"`
- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`
