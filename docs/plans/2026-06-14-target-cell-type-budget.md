---
title: Target Cell Type Budget
type: reliability
date: 2026-06-14
status: planned
execution: code
---

# Target Cell Type Budget

## Summary

Bound target cell-type normalization to the 256 columns supported by the
maintained BIFF `.xls` reader. Reject oversized or unbounded iterables before
opening a workbook instead of eagerly materializing arbitrary input.

## Prioritized Engineering Tasks

1. Replace eager `list(cell_types)` normalization with a bounded 257-item probe.
2. Preserve `None`, finite iterable, value-validation, and callback behavior.
3. Reject the 257th target type with a stable `InvalidDataException` before
   workbook access.
4. Add executable and static contracts for exact-limit, over-limit, and
   unbounded iterable inputs.

## Requirements

- R1. Accept at most 256 target cell types, matching `xlrd`'s `.xls` column
  boundary.
- R2. Consume at most 257 entries from any iterable to determine overflow.
- R3. Preserve existing validation for non-iterables, booleans, floats, and
  unsupported integer target types.
- R4. Reject oversized schemas before `xlrd.open_workbook` and before callbacks.
- R5. Keep the full Python 3.10, 3.12, and 3.14 hosted matrix and dependency
  audit authoritative for the stacked PR.

## Non-Goals

- Supporting `.xlsx` files or more than 256 `.xls` columns.
- Changing row conversion, callback, completion, or workbook-release behavior.
- Adding dependencies or modifying the lock-free requirements files.

## Planned Verification

- Focused parser unit tests for 256 entries, 257 entries, and an unbounded
  iterable with a consumption counter.
- Full `make check` on available Python runtimes and from an external working
  directory.
- Isolated hostile mutations for the limit, bounded probe, overflow rejection,
  test coverage, documentation, and completed-plan evidence.
- Exact intended-path, bytecode artifact, whitespace, conflict-marker, and
  changed-line credential-pattern audits.
