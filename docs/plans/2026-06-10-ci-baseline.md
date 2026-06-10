# Excel Parser CI Baseline

status: completed

## Context

The parser has a local `make check` baseline for Python 3 unit tests, syntax
checks, and optional Python 2 compatibility when that runtime is installed. The
missing guard was a hosted workflow that repeats the Python 3 baseline.

## Changes

- Added `.github/workflows/check.yml` for GitHub Actions.
- Installed pinned runtime and audit dependencies on Python 3.10, 3.12, and
  3.14.
- Ran `make check`, including `pip-audit`, on pushes, pull requests, and manual
  dispatches.
- Pinned workflow actions by commit, granted read-only repository access,
  enabled stale-run cancellation, and limited jobs to ten minutes.
- Extended the maintenance checker and docs so hosted CI stays part of the
  project baseline.

## Verification

- Clean installs and `make check` on Python 3.10, 3.12, and 3.14
- `git diff --check`
