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
CHECKOUT_CREDENTIAL_PLAN="$ROOT_DIR/docs/plans/2026-06-12-checkout-credential-boundary.md"
CALLBACK_VALIDATION_PLAN="$ROOT_DIR/docs/plans/2026-06-13-callback-validation.md"
PYTHON3_RUNTIME_PLAN="$ROOT_DIR/docs/plans/2026-06-13-python3-runtime-baseline.md"
COMPLETION_ORDER_PLAN="$ROOT_DIR/docs/plans/2026-06-13-workbook-release-before-completion.md"
RELEASE_HOOK_PLAN="$ROOT_DIR/docs/plans/2026-06-13-workbook-release-hook-contract.md"
LOCATION_INDEPENDENT_MAKE_PLAN="$ROOT_DIR/docs/plans/2026-06-13-location-independent-make.md"
TARGET_TYPE_BUDGET_PLAN="$ROOT_DIR/docs/plans/2026-06-14-target-cell-type-budget.md"
CONTROL_CHARACTER_PLAN="$ROOT_DIR/docs/plans/2026-06-14-control-character-error-summaries.md"
CODEQL_PLAN="$ROOT_DIR/docs/plans/2026-06-14-codeql-analysis.md"

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
  "docs/plans/2026-06-12-checkout-credential-boundary.md" \
  "docs/plans/2026-06-13-callback-validation.md" \
  "docs/plans/2026-06-13-python3-runtime-baseline.md" \
  "docs/plans/2026-06-13-workbook-release-before-completion.md" \
  "docs/plans/2026-06-13-workbook-release-hook-contract.md" \
  "docs/plans/2026-06-13-location-independent-make.md" \
  "docs/plans/2026-06-14-target-cell-type-budget.md" \
  "docs/plans/2026-06-14-control-character-error-summaries.md" \
  "docs/plans/2026-06-14-codeql-analysis.md" \
  "docs/plans/2026-06-08-fractional-int-conversion.md" \
  "docs/plans/2026-06-08-excel-parser-maintenance-baseline.md"; do
  require_file "$path"
done

python3 - "$ROOT_DIR/parse.py" <<'PY'
import pathlib
import sys

source = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8")
process = source.split("    def process(", 1)[1].split("    def validate_callbacks", 1)[0]
release = 'release_resources()'
completion = 'self.parsedonecallback()'
if process.count(release) != 1 or process.count(completion) != 1:
    raise SystemExit("Workbook release and completion calls must remain unique.")
if process.index(release) > process.index(completion):
    raise SystemExit("Workbook resources must be released before parse completion is signaled.")
PY

python3 - "$ROOT_DIR/parse.py" <<'PY'
import pathlib
import sys

source = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8")
process = source.split("    def process(", 1)[1].split("    def validate_callbacks", 1)[0]
required = [
    'release_resources = getattr(book, "release_resources", None)',
    "if not callable(release_resources):",
    'raise InvalidDataException("Opened workbook must provide callable release_resources")',
    "sheet = book.sheet_by_name(sheet_name)",
]
positions = [process.find(item) for item in required]
if -1 in positions or positions != sorted(positions):
    raise SystemExit("Workbook release hook must be validated before sheet access.")
if "if release_resources is not None:" in process:
    raise SystemExit("Workbook release must not remain optional before completion.")
PY

for release_hook_contract in \
  "test_process_rejects_missing_release_hook_before_sheet_access" \
  "test_process_rejects_non_callable_release_hook_before_sheet_access" \
  'self.assertFalse(book.sheet_requested)' \
  'self.assertEqual([], completions)'; do
  if ! grep -Fq "$release_hook_contract" "$ROOT_DIR/tests/test_parse.py"; then
    printf '%s\n' "Workbook release-hook regression is missing: $release_hook_contract" >&2
    exit 1
  fi
done

if ! grep -Fq "status: completed" "$RELEASE_HOOK_PLAN" ||
  ! grep -Fq "Python 3.12.8 and Python 3.14.0" "$RELEASE_HOOK_PLAN" ||
  ! grep -Fq "hostile mutations were rejected" "$RELEASE_HOOK_PLAN"; then
  printf '%s\n' "Workbook release-hook plan must record truthful completed verification." >&2
  exit 1
fi

if ! grep -Fq "requires a callable resource-release hook" "$ROOT_DIR/README.md" ||
  ! grep -Fq "missing or non-callable release hook" "$ROOT_DIR/SECURITY.md" ||
  ! grep -Fq "Missing workbook release hooks fail before sheet access" "$ROOT_DIR/VISION.md" ||
  ! grep -Fq "Required a callable workbook release hook" "$ROOT_DIR/CHANGES.md" ||
  ! grep -Fq "Require callable workbook resource release" "$ROOT_DIR/AGENTS.md"; then
  printf '%s\n' "Project guidance must preserve the fail-closed workbook release-hook contract." >&2
  exit 1
fi

for completion_order_contract in \
  "test_process_releases_workbook_before_completion_callback" \
  "test_process_releases_workbook_before_raising_completion_callback" \
  "completion_states.append(book.released)" \
  'self.assertTrue(fake_xlrd.opened[0][2].released)'; do
  if ! grep -Fq "$completion_order_contract" "$ROOT_DIR/tests/test_parse.py"; then
    printf '%s\n' "Workbook completion-order regression is missing: $completion_order_contract" >&2
    exit 1
  fi
done

if ! grep -Fq "status: completed" "$COMPLETION_ORDER_PLAN" ||
  ! grep -Fq "Python 3.12.8 and Python 3.14.0" "$COMPLETION_ORDER_PLAN" ||
  ! grep -Fq "hostile mutations were rejected" "$COMPLETION_ORDER_PLAN" ||
  ! grep -Fq "No private workbook" "$COMPLETION_ORDER_PLAN"; then
  printf '%s\n' "Workbook completion-order plan must record truthful completed verification." >&2
  exit 1
fi

if ! grep -Fq "resources are released before the parse-completion callback" "$ROOT_DIR/README.md" ||
  ! grep -Fq "resources are released before a successful parse invokes" "$ROOT_DIR/SECURITY.md" ||
  ! grep -Fq "Workbook release completes before the parse-completion callback" "$ROOT_DIR/VISION.md" ||
  ! grep -Fq "Released workbook resources before invoking" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Project docs must preserve workbook release-before-completion ordering." >&2
  exit 1
fi

(cd "$ROOT_DIR" && python3 -m py_compile parse.py tests/test_parse.py tests/test_xls_integration.py)
(cd "$ROOT_DIR" && python3 -m unittest discover -s tests -p "test*.py")

if ! grep -Fq "status: completed" "$PLAN"; then
  printf '%s\n' "Plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "make check" "$ROOT_DIR/README.md" ||
  ! grep -Fq "GitHub Actions" "$ROOT_DIR/README.md" ||
  ! grep -Fq "make build" "$ROOT_DIR/README.md" ||
  ! grep -Fq "xlrd" "$ROOT_DIR/README.md" ||
  ! grep -Fq "Python 3.10 or newer" "$ROOT_DIR/README.md" ||
  ! grep -Fq "synthetic" "$ROOT_DIR/README.md" ||
  ! grep -Fq "fractional" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the check command, xlrd dependency, legacy Python posture, and fixture safety." >&2
  exit 1
fi

if ! grep -Fq "non-string text cells" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document non-string text-cell validation." >&2
  exit 1
fi

if ! grep -Fq "Conversion errors summarize long, multiline, or unprintable values and escape" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document conversion error value summaries." >&2
  exit 1
fi

for control_character_contract in \
  'character.isprintable()' \
  'repr(character)[1:-1]' \
  'summary_length + len(token) > MAX_ERROR_VALUE_LENGTH' \
  'test_conversion_errors_escape_control_characters' \
  'test_conversion_error_summary_preserves_printable_unicode' \
  'test_conversion_error_summary_bounds_complete_escape_tokens'; do
  if ! grep -Fq "$control_character_contract" "$ROOT_DIR/parse.py" "$ROOT_DIR/tests/test_parse.py"; then
    printf '%s\n' "Control-character error-summary contract is missing: $control_character_contract" >&2
    exit 1
  fi
done

if ! grep -Fq "status: completed" "$CONTROL_CHARACTER_PLAN" ||
  ! grep -Fq "make check" "$CONTROL_CHARACTER_PLAN" ||
  ! grep -Fq "hostile mutations" "$CONTROL_CHARACTER_PLAN"; then
  printf '%s\n' "Control-character error-summary plan must remain completed with verification recorded." >&2
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
  "not isinstance(cell_type, int)" \
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
  ! grep -Fq "Clean Python 3.12.8 and 3.14.0 environments: \`make check\` passed all 22 tests," "$REAL_XLS_PLAN" ||
  ! grep -Fq "GitHub Actions run \`27391562146\` passed on Python 3.10, 3.12, and 3.14." "$REAL_XLS_PLAN" ||
  ! grep -Fq "Five isolated hostile mutations were rejected" "$REAL_XLS_PLAN"; then
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

if ! grep -Fq "escape terminal or log control characters" "$ROOT_DIR/SECURITY.md"; then
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
  ! grep -Fq 'name: CodeQL (${{ matrix.language }})' "$CI_WORKFLOW" ||
  ! grep -Fq "security-events: write" "$CI_WORKFLOW" ||
  ! grep -Fq "language: [actions, python]" "$CI_WORKFLOW" ||
  ! grep -Fq "github/codeql-action/init@8aad20d150bbac5944a9f9d289da16a4b0d87c1e # v4" "$CI_WORKFLOW" ||
  ! grep -Fq 'languages: ${{ matrix.language }}' "$CI_WORKFLOW" ||
  ! grep -Fq "build-mode: none" "$CI_WORKFLOW" ||
  ! grep -Fq "github/codeql-action/analyze@8aad20d150bbac5944a9f9d289da16a4b0d87c1e # v4" "$CI_WORKFLOW" ||
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

if [ "$(grep -Fc "uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10" "$CI_WORKFLOW")" -ne 2 ] ||
  [ "$(grep -Fc "persist-credentials: false" "$CI_WORKFLOW")" -ne 2 ] ||
  [ "$(grep -Fc "security-events: write" "$CI_WORKFLOW")" -ne 1 ] ||
  [ "$(grep -Fc "github/codeql-action/" "$CI_WORKFLOW")" -ne 2 ]; then
  printf '%s\n' "GitHub Actions must use two pinned credential-free checkouts and one CodeQL upload permission." >&2
  exit 1
fi

if ! awk '
  /uses: actions\/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10/ { checkout = 1; options = 0; next }
  checkout && /^[[:space:]]+with:[[:space:]]*$/ { options = 1; next }
  checkout && options && /^[[:space:]]+persist-credentials: false[[:space:]]*$/ { protected += 1; checkout = 0; options = 0; next }
  checkout && /^[[:space:]]+- / { checkout = 0; options = 0 }
  END { exit protected == 2 ? 0 : 1 }
' "$CI_WORKFLOW"; then
  printf '%s\n' "Checkout credential persistence must be disabled on both pinned checkout steps." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$CODEQL_PLAN" ||
  ! grep -Fq 'The repository and external-directory `make check` passed.' "$CODEQL_PLAN" ||
  ! grep -Fq "hostile CodeQL workflow mutations were rejected" "$CODEQL_PLAN"; then
  printf '%s\n' "CodeQL plan must record completed status and verification." >&2
  exit 1
fi

for codeql_evidence in \
  "$ROOT_DIR/README.md:GitHub Actions and Python" \
  "$ROOT_DIR/README.md:security-events: write" \
  "$ROOT_DIR/SECURITY.md:Pinned CodeQL analysis" \
  "$ROOT_DIR/VISION.md:Keep pinned CodeQL coverage" \
  "$ROOT_DIR/CHANGES.md:least-privilege CodeQL analysis"; do
  evidence_file=${codeql_evidence%%:*}
  evidence_contract=${codeql_evidence#*:}
  if ! grep -Fq -- "$evidence_contract" "$evidence_file"; then
    printf '%s\n' "$evidence_file is missing CodeQL evidence: $evidence_contract" >&2
    exit 1
  fi
done

if ! grep -Fxq "xlrd==2.0.2" "$ROOT_DIR/requirements.txt" ||
  ! grep -Fxq "pip-audit==2.10.0" "$ROOT_DIR/requirements-dev.txt" ||
  ! grep -Fxq "xlwt==1.3.0" "$ROOT_DIR/requirements-dev.txt" ||
  ! grep -Fq 'python3 -m pip_audit -r "$(ROOT)/requirements.txt" -r "$(ROOT)/requirements-dev.txt"' "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Dependency and audit contracts must remain pinned." >&2
  exit 1
fi

if grep -Fq "except Exception," "$ROOT_DIR/parse.py" ||
  ! grep -Fq "_MissingXlrd" "$ROOT_DIR/parse.py" ||
  ! grep -Fq "isinstance(data, str)" "$ROOT_DIR/parse.py" ||
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

for obsolete_python_contract in \
  "basestring" \
  "integer_types" \
  "string_types" \
  "int, long" \
  "class _MissingXlrd(object)" \
  "class ExcelProcessor(object)" \
  "class FakeSheet(object)" \
  "class FakeBook(object)" \
  "class FakeXlrd(object)"; do
  if grep -Fq "$obsolete_python_contract" "$ROOT_DIR/parse.py" "$ROOT_DIR/tests/test_parse.py"; then
    printf '%s\n' "Dormant Python 2 compatibility contract returned: $obsolete_python_contract" >&2
    exit 1
  fi
done

python3 - "$ROOT_DIR/scripts/check-baseline.sh" <<'PY'
from pathlib import Path
import sys

source = Path(sys.argv[1]).read_text(encoding="utf-8")
runtime = "python" + "2"
if "command -v " + runtime in source or runtime + " -m py_compile" in source:
    raise SystemExit("The maintained gate must not retain optional Python 2 compilation.")
PY

if ! grep -Fq "test_public_callback_api_signatures_are_preserved" "$ROOT_DIR/tests/test_parse.py" ||
  ! grep -Fq "inspect.signature(parse.ExcelProcessor.__init__)" "$ROOT_DIR/tests/test_parse.py" ||
  ! grep -Fq "inspect.signature(parse.ExcelProcessor.process)" "$ROOT_DIR/tests/test_parse.py" ||
  ! grep -Fq 'constructor.parameters["exceptioncallback"].default' "$ROOT_DIR/tests/test_parse.py" ||
  ! grep -Fq 'process.parameters["cell_types"].default' "$ROOT_DIR/tests/test_parse.py"; then
  printf '%s\n' "Python 3 migration must preserve the public callback API signatures." >&2
  exit 1
fi

for document in "$ROOT_DIR/README.md" "$ROOT_DIR/AGENTS.md" "$ROOT_DIR/SECURITY.md" "$ROOT_DIR/VISION.md" "$ROOT_DIR/CHANGES.md"; do
  if ! grep -Fq "Python 3.10" "$document"; then
    printf '%s\n' "$document must document the maintained Python 3.10+ runtime." >&2
    exit 1
  fi
done

if grep -Fq "Port to supported Python syntax in a dedicated pass" "$ROOT_DIR/VISION.md"; then
  printf '%s\n' "VISION must move the completed Python runtime port out of next priorities." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$PYTHON3_RUNTIME_PLAN" ||
  ! grep -Fq "Python 3.12.8 and Python 3.14.0" "$PYTHON3_RUNTIME_PLAN" ||
  ! grep -Fq "hostile mutations were rejected" "$PYTHON3_RUNTIME_PLAN" ||
  ! grep -Fq "temporary synthetic .xls" "$PYTHON3_RUNTIME_PLAN"; then
  printf '%s\n' "Python 3 runtime plan must record truthful completed verification." >&2
  exit 1
fi

for callback_contract in \
  "def validate_callbacks(self)" \
  "if not callable(self.rowdatacallback)" \
  "if not callable(self.parsedonecallback)" \
  "self.exceptioncallback is not None and not callable(self.exceptioncallback)" \
  "Row data callback must be callable" \
  "Parse completion callback must be callable" \
  "Exception callback must be callable or None"; do
  if ! grep -Fq "$callback_contract" "$ROOT_DIR/parse.py"; then
    printf '%s\n' "Parser callback contract is missing: $callback_contract" >&2
    exit 1
  fi
done

python3 - "$ROOT_DIR/parse.py" <<'PY'
import pathlib
import sys

source = pathlib.Path(sys.argv[1]).read_text()
try:
    process = source.index("    def process(self, excel, sheet_name, has_header, cell_types=None):")
    callback_validation = source.index("        self.validate_callbacks()", process)
    cell_type_validation = source.index("        cell_types = self.validate_cell_types(cell_types)", process)
    workbook_open = source.index("        book = xlrd.open_workbook(excel, on_demand=True)", process)
except ValueError as exc:
    raise SystemExit("Callback validation process boundary is missing") from exc

if not process < callback_validation < cell_type_validation < workbook_open:
    raise SystemExit("Callback validation must be the first process boundary before workbook access")
PY

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
  ! grep -Fq "test_process_rejects_non_callable_row_callback_before_opening_workbook" "$ROOT_DIR/tests/test_parse.py" ||
  ! grep -Fq "test_process_rejects_non_callable_done_callback_before_opening_workbook" "$ROOT_DIR/tests/test_parse.py" ||
  ! grep -Fq "test_process_rejects_non_callable_exception_callback_before_opening_workbook" "$ROOT_DIR/tests/test_parse.py" ||
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

if ! grep -Fq "status: completed" "$CHECKOUT_CREDENTIAL_PLAN" ||
  ! grep -Fq 'Python 3.12 `make check` passed' "$CHECKOUT_CREDENTIAL_PLAN" ||
  ! grep -Fq "external working directory" "$CHECKOUT_CREDENTIAL_PLAN" ||
  ! grep -Fq "hostile mutations were rejected" "$CHECKOUT_CREDENTIAL_PLAN"; then
  printf '%s\n' "Checkout credential boundary plan must record completed verification." >&2
  exit 1
fi

if ! grep -Fq "does not persist checkout credentials" "$ROOT_DIR/README.md" ||
  ! grep -Fq "does not persist checkout credentials" "$ROOT_DIR/SECURITY.md" ||
  ! grep -Fq "credential-free checkout" "$ROOT_DIR/VISION.md" ||
  ! grep -Fq "Stopped GitHub Actions checkout credential persistence" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Project guidance must document the checkout credential boundary." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$CALLBACK_VALIDATION_PLAN" ||
  ! grep -Fq "all 25 unit and integration tests passed" "$CALLBACK_VALIDATION_PLAN" ||
  ! grep -Fq "callback validation failed" "$CALLBACK_VALIDATION_PLAN" ||
  ! grep -Fq "validation after workbook option checks failed" "$CALLBACK_VALIDATION_PLAN"; then
  printf '%s\n' "Callback validation plan must record completed verification." >&2
  exit 1
fi

if ! grep -Fq "Callbacks are validated before opening a workbook" "$ROOT_DIR/README.md" ||
  ! grep -Fq "Callback slots must be validated before opening workbook files" "$ROOT_DIR/SECURITY.md" ||
  ! grep -Fq "Callback configuration fails fast before workbook files are opened" "$ROOT_DIR/VISION.md" ||
  ! grep -Fq "Validated parser callbacks before opening workbook files" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Project guidance must document fail-fast callback validation." >&2
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

if ! grep -Fq 'ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))' "$ROOT_DIR/Makefile" ||
  ! grep -Fq '"$(ROOT)/scripts/check-baseline.sh"' "$ROOT_DIR/Makefile" ||
  ! grep -Fq 'cd "$(ROOT)" && python3 -m unittest discover' "$ROOT_DIR/Makefile" ||
  ! grep -Fq '"$(ROOT)/parse.py"' "$ROOT_DIR/Makefile" ||
  ! grep -Fq '"$(ROOT)/requirements.txt"' "$ROOT_DIR/Makefile" ||
  ! grep -Fq '"$(ROOT)/requirements-dev.txt"' "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile verification commands must resolve paths from the loaded Makefile." >&2
  exit 1
fi

if ! grep -Eq '^\(cd "\$ROOT_DIR" && python3 -m py_compile parse\.py tests/test_parse\.py tests/test_xls_integration\.py\)$' "$ROOT_DIR/scripts/check-baseline.sh" ||
  ! grep -Eq '^\(cd "\$ROOT_DIR" && python3 -m unittest discover -s tests -p "test\*\.py"\)$' "$ROOT_DIR/scripts/check-baseline.sh"; then
  printf '%s\n' "Baseline checker Python probes must run from the repository root." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$LOCATION_INDEPENDENT_MAKE_PLAN" ||
  ! grep -Fq "from /tmp" "$LOCATION_INDEPENDENT_MAKE_PLAN"; then
  printf '%s\n' "Location-independent Make plan must record completed status and external verification." >&2
  exit 1
fi

for target_type_budget_contract in \
  "MAX_TARGET_COLUMNS = 256" \
  "islice(iter(cell_types), MAX_TARGET_COLUMNS + 1)" \
  "Target cell types cannot exceed" \
  "test_process_accepts_exact_xls_target_column_limit" \
  "test_process_rejects_target_columns_above_xls_limit_before_opening_workbook" \
  "test_process_bounds_unbounded_target_type_iterables_before_workbook_access"; do
  if ! grep -Fq "$target_type_budget_contract" "$ROOT_DIR/parse.py" "$ROOT_DIR/tests/test_parse.py"; then
    printf '%s\n' "Target cell type budget contract is missing: $target_type_budget_contract" >&2
    exit 1
  fi
done

if ! grep -Fq "status: completed" "$TARGET_TYPE_BUDGET_PLAN" ||
  ! grep -Fq "make check" "$TARGET_TYPE_BUDGET_PLAN" ||
  ! grep -Fq "hostile mutations were rejected" "$TARGET_TYPE_BUDGET_PLAN"; then
  printf '%s\n' "Target cell type budget plan must record completed verification." >&2
  exit 1
fi

for document in "$ROOT_DIR/README.md" "$ROOT_DIR/SECURITY.md" "$ROOT_DIR/VISION.md" "$ROOT_DIR/CHANGES.md" "$ROOT_DIR/AGENTS.md"; do
  if ! grep -Fq "256 target columns" "$document"; then
    printf '%s\n' "$document must document the 256 target columns boundary." >&2
    exit 1
  fi
done

if ! grep -Fq "absolute Makefile path" "$ROOT_DIR/README.md" ||
  ! grep -Fq "working directory" "$ROOT_DIR/README.md" ||
  ! grep -Fq "Make verification resolves repository paths" "$ROOT_DIR/VISION.md" ||
  ! grep -Fq "External baseline" "$ROOT_DIR/AGENTS.md" ||
  ! grep -Fq "Made Make verification independent" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Project guidance must document location-independent Make verification." >&2
  exit 1
fi

if ! grep -Fq "xlrd==2.0.2" "$ROOT_DIR/requirements.txt" ||
  ! grep -Fq "__pycache__/" "$ROOT_DIR/.gitignore" ||
  ! grep -Fq "*.py[cod]" "$ROOT_DIR/.gitignore"; then
  printf '%s\n' "Dependency metadata and generated Python ignores must remain explicit." >&2
  exit 1
fi

printf '%s\n' "Excel Parser maintenance baseline checks passed."
