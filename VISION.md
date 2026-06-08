## Excel Parser Vision

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
- Avoid claiming date conversion support that the code does not implement
- Keep dependencies and Python 2 syntax constraints visible

Next priorities:

- Add a README with usage examples and supported `xlrd` versions
- Port to supported Python syntax in a dedicated pass
- Add tests for empty cells, missing columns, invalid conversions, and callbacks
- Decide whether modern `.xlsx` support is in scope

Contribution rules:

- One PR = one focused parser, test, or documentation change.
- Include small fixture workbooks for parser behavior when adding tests.
- Document unsupported conversions rather than silently accepting them.
- Keep callback behavior backward-compatible unless a migration note explains it.

## Security And Data

Excel files can contain sensitive data. Tests and examples should use synthetic
fixtures only, and parser errors should avoid dumping full row contents unless a
caller explicitly requests that behavior.

## What We Will Not Merge (For Now)

- Private spreadsheet data
- Broad parser rewrites without fixtures
- Date conversion claims without implementation and tests
- Dependency changes that make supported file formats ambiguous
