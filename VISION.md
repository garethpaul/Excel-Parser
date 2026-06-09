## Excel Parser Vision

This document explains the current state and direction of the project.
Project overview and developer docs: [`README.md`](README.md)

Excel Parser is a small Python 2-era `xlrd` helper for processing rows from a
named Excel sheet with declared target cell types and callbacks.

The repository is useful as a compact example of callback-driven spreadsheet
parsing and type conversion.

The goal is to keep the parser understandable while making Python version,
input validation, and supported Excel formats explicit.

The current focus is:

Priority:

- Preserve the row callback, completion callback, and exception callback API
- Keep type conversion behavior easy to inspect
- Avoid silent data loss when converting fractional numeric cells to integers
- Avoid claiming date conversion support that the code does not implement
- Keep dependencies and Python 2 syntax constraints visible

Current baseline:

- `parse.py` keeps the callback API while using Python 2/3-compatible syntax.
- Workbooks are opened on demand and release resources after processing.
- `xlrd` 2.x is documented as the real `.xls` workbook dependency; offline
  tests use synthetic fake workbooks.
- `make check` runs conversion, missing-cell, completion, and exception-callback
  coverage without private spreadsheet fixtures.
- Fractional numeric cells requested as integers raise `InvalidDataException`
  instead of being truncated.
- Blank or malformed text cells requested as numeric targets raise
  `InvalidDataException` instead of leaking raw Python conversion errors.
- Non-string text cells raise `InvalidDataException` instead of leaking
  attribute errors from conversion helpers.
- Non-finite numeric values are rejected before callbacks receive them.
- Numeric cells requested as text are still checked for non-finite values.
- Conversion errors summarize long, multiline, or unprintable values before caller error
  handlers receive them.
- Target cell type declarations fail fast before workbook files are opened.
- Date conversion remains explicitly unsupported.

Next priorities:

- Add real `.xls` fixture coverage using synthetic data if workbook integration
  behavior changes
- Port to supported Python syntax in a dedicated pass
- Decide whether modern `.xlsx` support is in scope

Contribution rules:

- One PR = one focused parser, test, or documentation change.
- Run `scripts/check-baseline.sh` before pushing parser changes.
- Use synthetic fixtures or fake workbook objects for parser behavior tests.
- Document unsupported conversions rather than silently accepting them.
- Keep callback behavior backward-compatible unless a migration note explains it.

## Security And Data

Canonical security policy and reporting:

- [`SECURITY.md`](SECURITY.md)

Excel files can contain sensitive data. Tests and examples should use synthetic
fixtures only, and parser errors should avoid dumping full row contents unless a
caller explicitly requests that behavior.

## What We Will Not Merge (For Now)

- Private spreadsheet data
- Broad parser rewrites without fixtures
- Date conversion claims without implementation and tests
- Dependency changes that make supported file formats ambiguous

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
