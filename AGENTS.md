# AGENTS.md

## Repository purpose

`garethpaul/Excel-Parser` is a small callback-driven Python helper for reading rows from a named Excel sheet with `xlrd` and converting cell values into declared target types.

## Project structure

- `Makefile` - repository verification targets
- `scripts` - baseline checks and helper scripts
- `docs` - plans, notes, and generated README assets
- `tests` - tests and fixtures
- `requirements.txt` - Python runtime dependencies

## Development commands

- Supported runtime: Python 3.10 or newer; hosted verification covers Python 3.10, 3.12, and 3.14.
- Install dependencies: `python3 -m pip install -r requirements.txt -r requirements-dev.txt`
- Full baseline: `make check`
- External baseline: `make -f /absolute/path/to/Makefile check`
- Lint/static checks: `make lint`
- Tests: `make test`
- Build: `make build`
- Dependency audit: `make audit`
- If a command above skips because a platform toolchain is missing, verify on a machine with that SDK before claiming platform behavior is tested.

## Coding conventions

- Prefer dependency-free tests or stdlib checks when legacy packages are unavailable.

## Testing guidance

- Test-related files detected: `tests/`, `tests/test_parse.py`
- Start with the narrowest relevant test or Make target, then run `make check` before handing off if the change is not documentation-only.
- Keep README verification notes in sync when commands, fixtures, or supported toolchains change.

## PR / change guidance

- Keep diffs focused on the requested repository and avoid unrelated modernization or formatting churn.
- Preserve public APIs, sample behavior, file formats, and documented environment variables unless the task explicitly changes them.
- Update tests, README notes, or docs/plans when behavior, security posture, or validation commands change.
- Call out skipped platform validation, legacy toolchain assumptions, and any risky files touched in the final summary.

## Safety and gotchas

- No required secret or credential file was identified in the repository scan. If you add integrations later, keep secrets out of git.
- Use synthetic spreadsheets or fake workbook objects in tests. Do not commit private spreadsheet data.
- Parser errors should avoid dumping full row contents unless a caller explicitly asks for that behavior.
- Real workbook paths must be non-empty `.xls` paths; `.xlsx` support is not part of the current `xlrd` 2.x contract.
- Validate the sheet name, boolean header flag, and exact integer target-type constants before opening a workbook. Do not accept booleans or numerically equivalent floats as schema aliases.
- Limit target schemas to 256 target columns and keep iterable normalization bounded before workbook access.
- Preserve strict conversion behavior: reject fractional integer conversions, blank or malformed numeric text, non-string text cells, non-finite numbers, unsupported dates, and unprintable or oversized raw values in errors.
- Keep `xlrd` and `pip-audit` pinned through reviewed dependency changes that pass the full Python matrix.
- Require callable workbook resource release before sheet access or completion
  callback delivery.
- Do not restore Python 2 compatibility branches (`basestring`, `long`, or old-style class inheritance); preserve the public callback signatures through Python 3 tests instead.
- See `SECURITY.md` for vulnerability reporting and safe research guidance.
- See `VISION.md` for project direction and contribution guardrails.
- See `docs/plans/2026-06-08-excel-parser-maintenance-baseline.md` for the current parser maintenance baseline.

## Agent workflow

1. Inspect the README, Makefile, manifests, and the files directly related to the request.
2. Make the smallest source or docs change that satisfies the task; avoid generated, vendored, or local-environment files unless required.
3. Run the narrowest useful validation first, then `make check` or the documented package/platform gate when available.
4. If a required SDK, service credential, or external runtime is unavailable, record the skipped command and why.
5. Summarize changed files, commands run, and remaining risks or follow-up validation.
