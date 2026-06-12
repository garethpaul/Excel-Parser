#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
PLAN="$ROOT_DIR/docs/plans/2026-06-08-excel-parser-maintenance-baseline.md"
NONFINITE_PLAN="$ROOT_DIR/docs/plans/2026-06-09-non-finite-number-conversion.md"
NONFINITE_TEXT_PLAN="$ROOT_DIR/docs/plans/2026-06-09-non-finite-number-text-conversion.md"
TEXT_VALUE_PLAN="$ROOT_DIR/docs/plans/2026-06-09-text-cell-value-validation.md"
ERROR_SUMMARY_PLAN="$ROOT_DIR/docs/plans/2026-06-09-conversion-error-value-summary.md"
TARGET_TYPES_PLAN="$ROOT_DIR/docs/plans/2026-06-09-target-cell-type-validation.md"
WORKBOOK_PATH_PLAN="$ROOT_DIR/docs/plans/2026-06-09-workbook-path-validation.md"
CI_WORKFLOW="$ROOT_DIR/.github/workflows/check.yml"
CI_PLAN="$ROOT_DIR/docs/plans/2026-06-10-ci-baseline.md"
OPTION_VALIDATION_PLAN="$ROOT_DIR/docs/plans/2026-06-10-processing-option-validation.md"
REAL_XLS_PLAN="$ROOT_DIR/docs/plans/2026-06-12-real-xls-integration-coverage.md"

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
  ".github/workflows/check.yml" \
  ".gitignore" \
  "CHANGES.md" \
  "Makefile" \
  "README.md" \
  "SECURITY.md" \
  "VISION.md" \
  "parse.py" \
  "requirements-dev.txt" \
  "requirements.txt" \
  "tests/test_parse.py" \
  "tests/test_xls_integration.py" \
  "docs/plans/2026-06-09-text-number-conversion-errors.md" \
  "docs/plans/2026-06-09-non-finite-number-conversion.md" \
  "docs/plans/2026-06-09-non-finite-number-text-conversion.md" \
  "docs/plans/2026-06-09-text-cell-value-validation.md" \
  "docs/plans/2026-06-09-conversion-error-value-summary.md" \
  "docs/plans/2026-06-09-target-cell-type-validation.md" \
  "docs/plans/2026-06-09-workbook-path-validation.md" \
  "docs/plans/2026-06-10-ci-baseline.md" \
  "docs/plans/2026-06-10-processing-option-validation.md" \
  "docs/plans/2026-06-12-real-xls-integration-coverage.md" \
  "docs/plans/2026-06-08-fractional-int-conversion.md" \
  "docs/plans/2026-06-08-excel-parser-maintenance-baseline.md"; do
  require_file "$path"
done

python3 -m py_compile "$ROOT_DIR/parse.py" "$ROOT_DIR/tests/test_parse.py" "$ROOT_DIR/tests/test_xls_integration.py"
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
  ! grep -Fq "GitHub Actions" "$ROOT_DIR/README.md" ||
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

if ! grep -Fq "Conversion errors summarize long, multiline, or unprintable values" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document conversion error value summaries." >&2
  exit 1
fi

if ! grep -Fq "Target cell type declarations are validated before opening workbooks" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document target cell type validation before workbook access." >&2
  exit 1
fi

if ! grep -Fq "Workbook paths are validated as non-empty .xls paths before opening files" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document workbook path validation before workbook access." >&2
  exit 1
fi

for option_contract in \
  "integer_types = (int, long)" \
  "or isinstance(cell_type, bool)" \
  "def validate_sheet_name" \
  "def validate_has_header" \
  "test_process_rejects_boolean_target_types_before_opening_workbook" \
  "test_process_rejects_float_target_types_before_opening_workbook" \
  "test_process_rejects_blank_sheet_name_before_opening_workbook" \
  "test_process_rejects_non_string_sheet_name_before_opening_workbook" \
  "test_process_rejects_non_boolean_header_flag_before_opening_workbook"; do
  if ! grep -Fq "$option_contract" "$ROOT_DIR/parse.py" "$ROOT_DIR/tests/test_parse.py"; then
    printf '%s\n' "Processing option validation contract is missing: $option_contract" >&2
    exit 1
  fi
done

if ! grep -Fq "Status: Completed" "$OPTION_VALIDATION_PLAN" ||
  ! grep -Fq "make check" "$OPTION_VALIDATION_PLAN"; then
  printf '%s\n' "Processing option validation plan must remain completed with verification recorded." >&2
  exit 1
fi

for integration_contract in \
  "self.assertIs(parse.xlrd, xlrd)" \
  "tempfile.TemporaryDirectory()" \
  'workbook.add_sheet("People")' \
  '("row", 1, ["Alice", 7, 3.5, None])' \
  '("row", 2, ["Bob", 8, 4.25, "ready"])' \
  '("done",)'; do
  if ! grep -Fq "$integration_contract" "$ROOT_DIR/tests/test_xls_integration.py"; then
    printf '%s\n' "Real XLS integration contract is missing: $integration_contract" >&2
    exit 1
  fi
done

if ! grep -Fq "Status: Completed" "$REAL_XLS_PLAN" ||
  ! grep -Fq "22 tests" "$REAL_XLS_PLAN" ||
  ! grep -Fq "Python 3.10, 3.12, and 3.14" "$REAL_XLS_PLAN"; then
  printf '%s\n' "Real XLS integration plan must remain completed with matrix verification recorded." >&2
  exit 1
fi

if ! grep -Fq "scripts/check-baseline.sh" "$ROOT_DIR/VISION.md" ||
  ! grep -Fq "GitHub Actions" "$ROOT_DIR/VISION.md" ||
  ! grep -Fq "fake workbook" "$ROOT_DIR/VISION.md" ||
  ! grep -Fq "date conversion" "$ROOT_DIR/VISION.md" ||
  ! grep -Fq "Fractional numeric cells" "$ROOT_DIR/VISION.md" ||
  ! grep -Fq "Conversion errors summarize" "$ROOT_DIR/VISION.md" ||
  ! grep -Fq "Workbook paths are validated" "$ROOT_DIR/VISION.md" ||
  ! grep -Fq "Target cell type declarations" "$ROOT_DIR/VISION.md" ||
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

if ! grep -Fq "Target cell type declarations should be validated before opening workbook files" "$ROOT_DIR/SECURITY.md"; then
  printf '%s\n' "SECURITY must document target cell type validation before workbook access." >&2
  exit 1
fi

if ! grep -Fq "Workbook paths should be validated as non-empty .xls paths before opening files" "$ROOT_DIR/SECURITY.md"; then
  printf '%s\n' "SECURITY must document workbook path validation before workbook access." >&2
  exit 1
fi

if ! grep -Fq "actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10" "$CI_WORKFLOW" ||
  ! grep -Fq "actions/setup-python@a309ff8b426b58ec0e2a45f0f869d46889d02405" "$CI_WORKFLOW" ||
  ! grep -Fq 'python-version: ["3.10", "3.12", "3.14"]' "$CI_WORKFLOW" ||
  ! grep -Fq 'python-version: ${{ matrix.python-version }}' "$CI_WORKFLOW" ||
  ! grep -Fq "python -m pip install -r requirements.txt -r requirements-dev.txt" "$CI_WORKFLOW" ||
  ! grep -Fq "permissions:" "$CI_WORKFLOW" ||
  ! grep -Fq "contents: read" "$CI_WORKFLOW" ||
  ! grep -Fq "workflow_dispatch:" "$CI_WORKFLOW" ||
  ! grep -Fq "cancel-in-progress: true" "$CI_WORKFLOW" ||
  ! grep -Fq "timeout-minutes: 10" "$CI_WORKFLOW" ||
  ! grep -Fq "make check" "$CI_WORKFLOW"; then
  printf '%s\n' "GitHub Actions workflow must run the pinned, read-only Python matrix." >&2
  exit 1
fi

if ! grep -Fxq "xlrd==2.0.2" "$ROOT_DIR/requirements.txt" ||
  ! grep -Fxq "pip-audit==2.10.0" "$ROOT_DIR/requirements-dev.txt" ||
  ! grep -Fxq "xlwt==1.3.0" "$ROOT_DIR/requirements-dev.txt" ||
  ! grep -Fq 'python3 -m pip_audit -r requirements.txt -r requirements-dev.txt' "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Dependency and audit contracts must remain pinned." >&2
  exit 1
fi

if grep -Fq "except Exception," "$ROOT_DIR/parse.py" ||
  ! grep -Fq "_MissingXlrd" "$ROOT_DIR/parse.py" ||
  ! grep -Fq "string_types" "$ROOT_DIR/parse.py" ||
  ! grep -Fq "MAX_ERROR_VALUE_LENGTH" "$ROOT_DIR/parse.py" ||
  ! grep -Fq "VALID_CELL_TYPES" "$ROOT_DIR/parse.py" ||
  ! grep -Fq "def validate_workbook_path" "$ROOT_DIR/parse.py" ||
  ! grep -Fq "excel = self.validate_workbook_path(excel)" "$ROOT_DIR/parse.py" ||
  ! grep -Fq 'lower().endswith(".xls")' "$ROOT_DIR/parse.py" ||
  ! grep -Fq "def validate_cell_types" "$ROOT_DIR/parse.py" ||
  ! grep -Fq "cell_types = self.validate_cell_types(cell_types)" "$ROOT_DIR/parse.py" ||
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
  ! grep -Fq "test_conversion_errors_handle_unprintable_values" "$ROOT_DIR/tests/test_parse.py" ||
  ! grep -Fq "test_non_finite_number_conversion_is_rejected" "$ROOT_DIR/tests/test_parse.py" ||
  ! grep -Fq "CELL_TEXT, value" "$ROOT_DIR/tests/test_parse.py" ||
  ! grep -Fq "test_process_rejects_invalid_target_types_before_opening_workbook" "$ROOT_DIR/tests/test_parse.py" ||
  ! grep -Fq "test_process_rejects_non_xls_workbook_path_before_opening_workbook" "$ROOT_DIR/tests/test_parse.py" ||
  ! grep -Fq "test_process_rejects_blank_workbook_path_before_opening_workbook" "$ROOT_DIR/tests/test_parse.py" ||
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
  ! grep -Fq "status: completed" "$TARGET_TYPES_PLAN" ||
  ! grep -Fq "Status: Completed" "$WORKBOOK_PATH_PLAN" ||
  ! grep -Fq "status: completed" "$CI_PLAN" ||
  ! grep -Fq "status: completed" "$ERROR_SUMMARY_PLAN"; then
  printf '%s\n' "Fractional integer conversion guard must be documented and planned." >&2
  exit 1
fi

if ! grep -Fq "GitHub Actions" "$CI_PLAN" || ! grep -Fq "make check" "$CI_PLAN"; then
  printf '%s\n' "CI baseline plan must record hosted make check verification." >&2
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

if ! grep -Fq "make check" "$TARGET_TYPES_PLAN"; then
  printf '%s\n' "Target cell type validation plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "make check" "$WORKBOOK_PATH_PLAN"; then
  printf '%s\n' "Workbook path validation plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "lint:" "$ROOT_DIR/Makefile" ||
  ! grep -Fq "test:" "$ROOT_DIR/Makefile" ||
  ! grep -Fq "build:" "$ROOT_DIR/Makefile" ||
  ! grep -Fq "check: lint test build" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must expose lint, test, build, and check gates." >&2
  exit 1
fi

if ! grep -Fq "xlrd==2.0.2" "$ROOT_DIR/requirements.txt" ||
  ! grep -Fq "__pycache__/" "$ROOT_DIR/.gitignore" ||
  ! grep -Fq "*.py[cod]" "$ROOT_DIR/.gitignore"; then
  printf '%s\n' "Dependency metadata and generated Python ignores must remain explicit." >&2
  exit 1
fi

printf '%s\n' "Excel Parser maintenance baseline checks passed."
