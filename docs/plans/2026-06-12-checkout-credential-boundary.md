# Excel Parser Checkout Credential Boundary

status: completed

## Context

The hosted workflow was globally read-only but checkout still persisted its
temporary token in local Git configuration after source retrieval.

## Changes

- Set `persist-credentials: false` on the single commit-pinned checkout step.
- Added exact structural contracts for checkout uniqueness and token isolation.
- Documented the boundary without changing parser behavior or dependencies.

## Verification

- Python 3.12 `make check` passed all 22 tests, compilation, and dependency audit.
- The rooted gate passed from an external working directory.
- Missing protection, duplicate checkout, incomplete evidence, and missing
  guidance hostile mutations were rejected.
- `git diff --check` and shell syntax validation passed.
