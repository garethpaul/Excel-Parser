# Workbook Path ValueError Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task.

**Goal:** Keep malformed workbook path strings inside the parser's `InvalidDataException` contract.

**Architecture:** Extend the existing `os.stat` boundary to translate both filesystem `OSError` and path-shape `ValueError` into the current validation error. Preserve all workbook, callback, and conversion behavior.

**Tech Stack:** Python 3.10/3.12/3.14, stdlib `os`/`stat`, `xlrd`, `unittest`, GNU Make.

---

status: completed

### Task 1: Prove the raw exception leak

**Files:**
- Modify: `tests/test_parse.py`

1. Process a non-empty `.xls` path containing an embedded NUL.
2. Require the existing accessible-regular-file `InvalidDataException`.
3. Prove the fake workbook opener remains untouched.
4. Run the focused test and confirm raw `ValueError` before implementation.

### Task 2: Contain malformed stat paths

**Files:**
- Modify: `parse.py`

1. Catch `ValueError` alongside `OSError` around `os.stat`.
2. Preserve the existing public validation message.
3. Rerun focused and full tests.

### Task 3: Preserve maintained contracts

**Files:**
- Add: `scripts/test-workbook-path-mutation.py`
- Modify: `scripts/check-baseline.sh`
- Modify: `README.md`
- Modify: `SECURITY.md`
- Modify: `VISION.md`
- Modify: `AGENTS.md`
- Modify: `CHANGES.md`

1. Add an isolated mutation that restores the raw `ValueError` leak.
2. Require source, test, guidance, and plan evidence.
3. Record red/green, matrix, hosted, and review evidence.

### Task 4: Validate and merge

**Files:**
- Verify only.

1. Run Python 3.10/3.12/3.14 gates, external Make, audit, mutation, and diff checks.
2. Push a focused PR and attempt Codex review.
3. Merge only the exact final head after hosted checks pass.

## Verification Completed

- Red: the embedded-NUL path leaked `ValueError: embedded null byte`.
- Green: focused and full tests pass with 49 tests.
- Python 3.12 and 3.14 `make check` pass with zero known vulnerabilities;
  external Make passes on Python 3.14.
- Python 3.10 compilation, tests, and static contracts pass; the embedded-NUL workbook path hostile mutation rejected the regression. Local `pip-audit`
  scratch-venv setup is blocked by unavailable `ensurepip`.
- Pending: hosted Python 3.10/3.12/3.14 checks, CodeQL, review, and merge.
