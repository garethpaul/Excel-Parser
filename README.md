# Excel-Parser

<!-- README-OVERVIEW-IMAGE -->
![Project overview](docs/readme-overview.svg)

## Overview

`garethpaul/Excel-Parser` is a small callback-driven Python helper for reading
rows from a named Excel sheet with `xlrd` and converting cell values into
declared target types.

The parser preserves a Python 2-era API, but `parse.py` is importable and
unit-tested under Python 3 for offline conversion and callback behavior.

## Repository Contents

- `parse.py` - Excel row processor and conversion helpers
- `tests/test_parse.py` - synthetic fake-workbook parser tests
- `requirements.txt` - `xlrd` dependency range for real `.xls` workbook parsing
- `Makefile` - local verification entry point
- `CHANGES.md` - maintenance history
- `SECURITY.md` - security reporting and disclosure guidance
- `VISION.md` - project direction and maintenance guardrails

## Getting Started

### Prerequisites

- Git
- Python 3 for local tests
- Python 2.7 when validating legacy syntax
- `xlrd>=2.0.1,<3` when processing real `.xls` workbook files

### Setup

```bash
git clone https://github.com/garethpaul/Excel-Parser.git
cd Excel-Parser
python3 -m pip install -r requirements.txt
```

The unit tests do not require a real workbook fixture; they use synthetic
workbook objects. Install `requirements.txt` when you need to process real
`.xls` files. Modern `.xlsx` support is intentionally not claimed by this
baseline.

## Running or Using the Project

- Instantiate `ExcelProcessor(row_callback, done_callback, exception_callback)`
  from `parse.py`.
- Call `process(path, sheet_name, has_header, cell_types)` with target cell
  types such as `ExcelProcessor.CELL_TEXT`, `CELL_INT`, and `CELL_FLOAT`.
- Use `ExcelProcessor.CELL_EMPTY` in `cell_types` to ignore a present source
  cell and receive `None` for that output position.
- Target cell type declarations are validated before opening workbooks, so
  invalid output schemas fail before file resources are touched.
- Numeric cells convert to `CELL_INT` only when the value is integer-valued;
  fractional numbers raise `InvalidDataException` instead of being truncated.
- Text cells requested as numeric targets reject blank or malformed text with
  `InvalidDataException`.
- non-string text cells are rejected with `InvalidDataException` before text,
  integer, or float conversion.
- Non-finite numeric values such as `nan` and `inf` are rejected before they
  reach callbacks, including when numeric cells are requested as text.
- Conversion errors summarize long, multiline, or unprintable values before raising
  `InvalidDataException`.
- Date conversion is intentionally unsupported and raises
  `InvalidDataException`.

## Testing and Verification

Run the local maintenance gate:

```bash
make check
make lint
make test
make build
```

`make check` runs Python 3 unit tests with synthetic workbook data, compiles the
parser under Python 3, and runs a Python 2 syntax check when `python2` is
available. `make lint` runs the full maintenance baseline, `make test` runs the
offline unittest suite, and `make build` compiles the parser and tests under
Python 3.

When the required SDK or runtime is unavailable, use static checks and source review first, then verify on a machine that has the matching platform toolchain.

## Configuration and Secrets

- No required secret or credential file was identified in the repository scan. If you add integrations later, keep secrets out of git.

## Security and Privacy Notes

- Review changes touching file, media, JSON, XML, CSV, OCR, or data parsing; examples from the scan include parse.py.
- Use synthetic spreadsheets or fake workbook objects in tests. Do not commit
  private spreadsheet data.
- Parser errors should avoid dumping full row contents unless a caller
  explicitly asks for that behavior.

## Maintenance Notes

- See `SECURITY.md` for vulnerability reporting and safe research guidance.
- See `VISION.md` for project direction and contribution guardrails.
- See `docs/plans/2026-06-08-excel-parser-maintenance-baseline.md` for the
  current parser maintenance baseline.
- See `docs/plans/2026-06-08-fractional-int-conversion.md` for numeric
  integer-conversion guardrails.
- See `docs/plans/2026-06-09-text-number-conversion-errors.md` for
  text-to-number conversion error guardrails.
- See `docs/plans/2026-06-09-non-finite-number-conversion.md` for non-finite
  numeric conversion guardrails.
- See `docs/plans/2026-06-09-non-finite-number-text-conversion.md` for
  non-finite numeric-to-text conversion guardrails.
- See `docs/plans/2026-06-09-text-cell-value-validation.md` for non-string
  text-cell validation.
- See `docs/plans/2026-06-09-conversion-error-value-summary.md` for bounded
  conversion error value summaries.
- See `docs/plans/2026-06-09-target-cell-type-validation.md` for target cell
  type validation before workbook access.

## Contributing

Keep changes small and tied to the project that is already present in this repository. For code changes, document the toolchain used, avoid committing generated dependency directories or local configuration, and update this README when setup or verification steps change.
