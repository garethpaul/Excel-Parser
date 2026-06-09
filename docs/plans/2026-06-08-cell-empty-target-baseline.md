---
title: CELL_EMPTY target baseline
date: 2026-06-08
status: completed
execution: code
---

## Context

`ExcelProcessor` exposes `CELL_EMPTY` alongside text, integer, float, and date
target constants. Empty source cells already produce `None`, but a non-empty
source cell targeting `CELL_EMPTY` raised `InvalidDataException`, making the
constant unusable for callers that want to skip a column while preserving output
positions.

## Requirements

- R1. `CELL_EMPTY` must be accepted as a target type for non-empty text and
  numeric source cells.
- R2. The returned value for a `CELL_EMPTY` target must be `None`.
- R3. Row processing must preserve callback output positions when a column is
  skipped with `CELL_EMPTY`.
- R4. Offline fake-workbook tests and the source baseline must cover the
  behavior.

## Verification

- `make check`
- `scripts/check-baseline.sh`
- `git diff --check`
