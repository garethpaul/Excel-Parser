---
title: Non-Finite Number Conversion
date: 2026-06-09
status: completed
execution: code
---

## Context

The parser converted numeric cells and text numeric values through `float()`.
Values such as `nan`, `inf`, and `-inf` are accepted by Python but are not
useful finite spreadsheet values for callbacks.

## Goals

- Reject non-finite numeric cell values requested as floats or integers.
- Reject text values such as `nan`, `inf`, and `-inf` requested as floats.
- Keep conversion failures wrapped in `InvalidDataException`.
- Preserve Python 2/3-compatible parser syntax.

## Verification

- `python3 -m unittest discover -s tests -p "test*.py"`
- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`
