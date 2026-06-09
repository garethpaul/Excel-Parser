# Conversion Error Value Summary

status: completed

## Context

Conversion failures included raw cell values in `InvalidDataException` messages.
That is useful for debugging, but long or multiline spreadsheet values can leak
more private data than needed into logs or caller error handlers.

## Objectives

- Preserve the existing callback API and `InvalidDataException` error type.
- Keep conversion error messages useful without dumping complete long values.
- Collapse multiline values before they appear in exception text.
- Fall back to a placeholder for values that cannot be stringified.
- Extend offline tests and the baseline so the formatter remains visible.

## Work Completed

- Added `MAX_ERROR_VALUE_LENGTH` and `format_error_value()` to bound invalid
  value summaries.
- Routed numeric, text, and non-string value conversion errors through the
  formatter.
- Added tests for long-value truncation, multiline normalization, and
  unprintable-value fallback.
- Extended `scripts/check-baseline.sh` to require the formatter, tests, docs,
  and completed plan.
- Documented the conversion error summary behavior in README, SECURITY, VISION,
  and CHANGES.

## Verification

- `sh -n scripts/check-baseline.sh`
- `scripts/check-baseline.sh`
- `python3 -m unittest discover -s tests -p "test*.py"`
- `make lint`
- `make test`
- `make build`
- `make check`
- `git diff --check`
