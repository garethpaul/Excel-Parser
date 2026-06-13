---
title: Location-Independent Make Verification
type: reliability
date: 2026-06-13
status: in progress
execution: code
---

# Location-Independent Make Verification

## Summary

Resolve verification paths from the loaded Makefile so the complete offline
gate works when invoked from outside the repository.

## Requirements

- R1. Derive the repository root from `MAKEFILE_LIST`.
- R2. Root checker, test discovery, compilation, requirement, and audit paths.
- R3. Preserve the selected `python3` from `PATH` and all 30 tests.
- R4. Add mutation-sensitive contracts and actual `/tmp` verification.
- R5. Do not alter parser behavior, dependencies, or workflow configuration.

## Verification Plan

- Run `make check` in pinned Python 3.12 and 3.14 environments.
- Run the absolute Makefile from `/tmp`.
- Reject hostile path, documentation, and completed-plan mutations.
- Run shell syntax, diff, exact-path, secret, and artifact checks.

## Non-Goals

- Changing parser callbacks, workbook behavior, dependency pins, or CI events.
