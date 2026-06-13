---
title: Excel Parser Python 3 Runtime Baseline
type: modernization
date: 2026-06-13
status: planned
---

# Excel Parser Python 3 Runtime Baseline

## Summary

Make the maintained Python 3.10+ runtime explicit and remove dormant Python 2
compatibility branches without changing the callback API, `.xls` format scope,
or conversion behavior.

## Problem Frame

The repository installs, tests, compiles, and audits on Python 3.10, 3.12, and
3.14, but `parse.py`, contributor guidance, and the static gate still preserve
`basestring`, `long`, old-style class syntax, and an optional Python 2 compile
path. That mixed contract obscures the supported runtime and keeps untested
branches in the parser. The vision lists a dedicated supported-Python port as
the next engineering priority.

## Requirements

- R1. Declare Python 3.10 or newer as the maintained runtime in project and
  contributor documentation.
- R2. Remove `basestring`, `long`, old-style `object` inheritance, and Python 2
  syntax verification from maintained code and gates.
- R3. Preserve the `ExcelProcessor` constructor and `process` callback API.
- R4. Preserve strict workbook, sheet, header, cell-schema, conversion, error
  redaction, resource-release, and callback behavior.
- R5. Keep `.xls` support through `xlrd==2.0.2`; do not claim `.xlsx` or date
  conversion support.
- R6. Run the complete unit and real-workbook integration suite on Python 3.10,
  3.12, and 3.14 in hosted CI, with available local 3.12/3.14 verification.
- R7. Enforce the runtime declaration, removed compatibility branches, tests,
  documentation, and completed verification in `make check`.

## Implementation Units

### U1. Remove Dormant Python 2 Branches

- **Files:** `parse.py`, `scripts/check-baseline.sh`
- **Goal:** Use direct Python 3 built-ins and class syntax and remove the
  conditional Python 2 compilation path.
- **Covers:** R1, R2, R3, R4

### U2. Regress The Preserved Public Contract

- **Files:** `tests/test_parse.py`, `tests/test_xls_integration.py`
- **Goal:** Keep callback order, conversion, validation, resource release, and
  real `.xls` behavior green under the explicit supported runtime.
- **Covers:** R3, R4, R5, R6

### U3. Document And Enforce The Runtime

- **Files:** `README.md`, `AGENTS.md`, `SECURITY.md`, `VISION.md`, `CHANGES.md`,
  this plan
- **Goal:** Replace mixed Python 2 wording with the supported matrix and retain
  unsupported format/conversion boundaries.
- **Covers:** R1, R5, R6, R7

## Verification Plan

- Run focused parser tests and full `make check` in fresh or existing pinned
  Python 3.12.8 and 3.14.0 environments.
- Apply isolated mutations for restored `basestring`, `long`, Python 2 compile
  logic, old runtime documentation, removed API regressions, roadmap drift, and
  incomplete plan evidence.
- Inspect exact paths, dependency manifests, credential-like additions,
  generated artifacts, and staged files before committing.
- Use no private workbooks; the real integration test must continue generating
  a temporary synthetic `.xls` file.

## Risks

- Python 2 consumers must remain on an older revision; this pass intentionally
  stops claiming untested compatibility.
- `.xlsx` and date conversion remain unsupported and are not migration targets
  in this change.
