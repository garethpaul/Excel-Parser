# Workbook Path Validation

Status: Completed
Date: 2026-06-09

## Goal

Fail fast for unsupported or malformed workbook path inputs before `xlrd` opens
file resources.

## Changes

- Added workbook path validation for non-empty `.xls` paths.
- Validated workbook paths before `xlrd.open_workbook` is called.
- Added fake-workbook tests proving `.xlsx` and blank paths are rejected before
  workbook access.
- Extended the source baseline, README, security notes, changelog, and vision
  with the workbook path validation contract.

## Verification

- `python3 -m unittest discover -s tests -p "test*.py"`
- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`
