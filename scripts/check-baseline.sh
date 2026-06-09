#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
PLAN="$ROOT_DIR/docs/plans/2026-06-08-excel-parser-maintenance-baseline.md"
NONFINITE_PLAN="$ROOT_DIR/docs/plans/2026-06-09-non-finite-number-conversion.md"
NONFINITE_TEXT_PLAN="$ROOT_DIR/docs/plans/2026-06-09-non-finite-number-text-conversion.md"
TEXT_VALUE_PLAN="$ROOT_DIR/docs/plans/2026-06-09-text-cell-value-validation.md"
ERROR_SUMMARY_PLAN="$ROOT_DIR/docs/plans/2026-06-09-conversion-error-value-summary.md"

cleanup_bytecode() {
  find "$ROOT_DIR" -maxdepth 3 -type d -name "__pycache__" -prune -exec rm -rf {} + 2>/dev/null || true
  find "$ROOT_DIR" -maxdepth 3 -type f -name "*.pyc" -delete 2>/dev/null || true
}

trap cleanup_bytecode EXIT

require_file() {
  path=$1
  if [ ! -f "$ROOT_DIR/$path" ]; then
    printf '%s\n' "Required file missing: $path" >&2
    exit 1
  fi
}

for path in \
  ".gitignore" \
  "CHANGES.md" \
  "Makefile" \
  "README.md" \
  "SECURITY.md" \
  "VISION.md" \
  "parse.py" \
  "requirements.txt" \
  "tests/test_parse.py" \
  "docs/plans/2026-06-09-text-number-conversion-errors.md" \
  "docs/plans/2026-06-09-non-finite-number-conversion.md" \
  "docs/plans/2026-06-09-non-finite-number-text-conversion.md" \
  "docs/plans/2026-06-09-text-cell-value-validation.md" \
  "docs/plans/2026-06-09-conversion-error-value-summary.md" \
  "docs/plans/2026-06-08-fractional-int-conversion.md" \
  "docs/plans/2026-06-08-excel-parser-maintenance-baseline.md"; do
  require_file "$path"
done

python3 -m py_compile "$ROOT_DIR/parse.py" "$ROOT_DIR/tests/test_parse.py"
python3 -m unittest discover -s "$ROOT_DIR/tests" -p "test*.py"

if command -v python2 >/dev/null 2>&1; then
  python2 -m py_compile "$ROOT_DIR/parse.py"
else
  printf '%s\n' "Skipping Python 2 compile check: python2 is not installed."
fi

if ! grep -Fq "status: completed" "$PLAN"; then
  printf '%s\n' "Plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "make check" "$ROOT_DIR/README.md" ||
  ! grep -Fq "make build" "$ROOT_DIR/README.md" ||
  ! grep -Fq "xlrd" "$ROOT_DIR/README.md" ||
  ! grep -Fq "Python 2" "$ROOT_DIR/README.md" ||
  ! grep -Fq "synthetic" "$ROOT_DIR/README.md" ||
  ! grep -Fq "fractional" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the check command, xlrd dependency, legacy Python posture, and fixture safety." >&2
  exit 1
fi

if ! grep -Fq "non-string text cells" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document non-string text-cell validation." >&2
  exit 1
fi

if ! grep -Fq "Conversion errors summarize long or multiline values" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document conversion error value summaries." >&2
  exit 1
fi

if ! grep -Fq "scripts/check-baseline.sh" "$ROOT_DIR/VISION.md" ||
  ! grep -Fq "fake workbook" "$ROOT_DIR/VISION.md" ||
  ! grep -Fq "date conversion" "$ROOT_DIR/VISION.md" ||
  ! grep -Fq "Fractional numeric cells" "$ROOT_DIR/VISION.md" ||
  ! grep -Fq "Conversion errors summarize" "$ROOT_DIR/VISION.md" ||
  ! grep -Fq "Non-string text cells" "$ROOT_DIR/VISION.md"; then
  printf '%s\n' "VISION must describe the current parser baseline and date-conversion boundary." >&2
  exit 1
fi

if ! grep -Fq "Non-string text cells" "$ROOT_DIR/SECURITY.md"; then
  printf '%s\n' "SECURITY must document non-string text-cell validation." >&2
  exit 1
fi

if ! grep -Fq "Conversion error messages should summarize" "$ROOT_DIR/SECURITY.md"; then
  printf '%s\n' "SECURITY must document conversion error value summaries." >&2
  exit 1
fi

if grep -Fq "except Exception," "$ROOT_DIR/parse.py" ||
  ! grep -Fq "_MissingXlrd" "$ROOT_DIR/parse.py" ||
  ! grep -Fq "string_types" "$ROOT_DIR/parse.py" ||
  ! grep -Fq "MAX_ERROR_VALUE_LENGTH" "$ROOT_DIR/parse.py" ||
  ! grep -Fq "def format_error_value" "$ROOT_DIR/parse.py" ||
  ! grep -Fq "value.splitlines()" "$ROOT_DIR/parse.py" ||
  ! grep -Fq "cell_types=None" "$ROOT_DIR/parse.py" ||
  ! grep -Fq "newtype == ExcelProcessor.CELL_EMPTY" "$ROOT_DIR/parse.py" ||
  ! grep -Fq "def convert_number_to_int" "$ROOT_DIR/parse.py" ||
  ! grep -Fq "def convert_number_to_float" "$ROOT_DIR/parse.py" ||
  ! grep -Fq "def clean_text" "$ROOT_DIR/parse.py" ||
  ! grep -Fq "def convert_text_to_int" "$ROOT_DIR/parse.py" ||
  ! grep -Fq "def convert_text_to_float" "$ROOT_DIR/parse.py" ||
  ! grep -Fq "self.convert_number_to_float(data)" "$ROOT_DIR/parse.py" ||
  ! grep -Fq "math.isnan(number)" "$ROOT_DIR/parse.py" ||
  ! grep -Fq "math.isinf(number)" "$ROOT_DIR/parse.py" ||
  ! grep -Fq "number.is_integer()" "$ROOT_DIR/parse.py" ||
  ! grep -Fq "Empty text value cannot be converted to int" "$ROOT_DIR/parse.py" ||
  ! grep -Fq "Text value cannot be converted to float" "$ROOT_DIR/parse.py" ||
  ! grep -Fq "except Exception as exc" "$ROOT_DIR/parse.py" ||
  ! grep -Fq "on_demand=True" "$ROOT_DIR/parse.py" ||
  ! grep -Fq "release_resources" "$ROOT_DIR/parse.py"; then
  printf '%s\n' "Parser must stay importable under Python 3 while preserving the legacy callback API." >&2
  exit 1
fi

if ! grep -Fq "FakeXlrd" "$ROOT_DIR/tests/test_parse.py" ||
  ! grep -Fq "test_process_skips_header_and_handles_missing_cells" "$ROOT_DIR/tests/test_parse.py" ||
  ! grep -Fq "test_process_allows_cell_empty_targets_to_skip_present_values" "$ROOT_DIR/tests/test_parse.py" ||
  ! grep -Fq "test_number_to_int_rejects_fractional_values" "$ROOT_DIR/tests/test_parse.py" ||
  ! grep -Fq "test_text_to_number_rejects_blank_values_with_parser_exception" "$ROOT_DIR/tests/test_parse.py" ||
  ! grep -Fq "test_text_to_number_rejects_invalid_values_with_parser_exception" "$ROOT_DIR/tests/test_parse.py" ||
  ! grep -Fq "test_text_conversions_reject_non_string_values_with_parser_exception" "$ROOT_DIR/tests/test_parse.py" ||
  ! grep -Fq "test_conversion_errors_summarize_long_text_values" "$ROOT_DIR/tests/test_parse.py" ||
  ! grep -Fq "test_conversion_errors_normalize_multiline_text_values" "$ROOT_DIR/tests/test_parse.py" ||
  ! grep -Fq "test_non_finite_number_conversion_is_rejected" "$ROOT_DIR/tests/test_parse.py" ||
  ! grep -Fq "CELL_TEXT, value" "$ROOT_DIR/tests/test_parse.py" ||
  ! grep -Fq "test_exception_callback_receives_row_errors_and_processing_continues" "$ROOT_DIR/tests/test_parse.py"; then
  printf '%s\n' "Offline tests must cover fake-workbook processing and callback error behavior." >&2
  exit 1
fi

if ! grep -Fq "fractional numeric" "$ROOT_DIR/CHANGES.md" ||
  ! grep -Fq "text-to-number" "$ROOT_DIR/CHANGES.md" ||
  ! grep -Fq "non-finite" "$ROOT_DIR/CHANGES.md" ||
  ! grep -Fq "status: completed" "$ROOT_DIR/docs/plans/2026-06-08-fractional-int-conversion.md" ||
  ! grep -Fq "status: completed" "$ROOT_DIR/docs/plans/2026-06-09-text-number-conversion-errors.md" ||
  ! grep -Fq "status: completed" "$NONFINITE_PLAN" ||
  ! grep -Fq "status: completed" "$NONFINITE_TEXT_PLAN" ||
  ! grep -Fq "status: completed" "$TEXT_VALUE_PLAN" ||
  ! grep -Fq "status: completed" "$ERROR_SUMMARY_PLAN"; then
  printf '%s\n' "Fractional integer conversion guard must be documented and planned." >&2
  exit 1
fi

if ! grep -Fq "make check" "$TEXT_VALUE_PLAN"; then
  printf '%s\n' "Text cell value validation plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "make check" "$NONFINITE_TEXT_PLAN"; then
  printf '%s\n' "Non-finite numeric-to-text plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "make check" "$ERROR_SUMMARY_PLAN"; then
  printf '%s\n' "Conversion error value summary plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "lint:" "$ROOT_DIR/Makefile" ||
  ! grep -Fq "test:" "$ROOT_DIR/Makefile" ||
  ! grep -Fq "build:" "$ROOT_DIR/Makefile" ||
  ! grep -Fq "check: lint test build" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must expose lint, test, build, and check gates." >&2
  exit 1
fi

if ! grep -Fq "xlrd>=2.0.1,<3" "$ROOT_DIR/requirements.txt" ||
  ! grep -Fq "__pycache__/" "$ROOT_DIR/.gitignore" ||
  ! grep -Fq "*.py[cod]" "$ROOT_DIR/.gitignore"; then
  printf '%s\n' "Dependency metadata and generated Python ignores must remain explicit." >&2
  exit 1
fi

printf '%s\n' "Excel Parser maintenance baseline checks passed."
