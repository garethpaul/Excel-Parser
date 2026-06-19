# Security Policy

## Supported Versions

The supported security scope for `Excel-Parser` is the current default branch, `master`. Older commits, tags, branches, forks, demos, and generated artifacts are not actively supported unless the repository explicitly marks them as maintained.

Project summary: Excel Parser for XLRD

## Reporting a Vulnerability

Please report suspected vulnerabilities through GitHub's private vulnerability reporting or by opening a draft GitHub Security Advisory for `garethpaul/Excel-Parser` when that option is available. If GitHub does not show a private reporting option for this repository, contact the repository owner through GitHub and avoid posting exploit details publicly until the issue can be assessed.

Do not open a public issue that includes exploit code, secrets, personal data, or detailed reproduction steps for an unpatched vulnerability.

## What to Include

Helpful reports include:

- the affected file, endpoint, permission, dependency, or workflow
- a concise impact statement explaining what an attacker could do
- reproduction steps using test data and accounts you control
- the branch, commit SHA, platform version, device, runtime, or dependency versions used
- logs, screenshots, or proof-of-concept snippets that demonstrate impact without exposing private data

## Project Security Posture

- This repository appears to be a public sample, documentation, or utility project. The active security scope is the code and documentation on the default branch.
- Review found file, document, data, or media parsing flows; changes in those areas should receive security-focused review before merge.
- Review found database, model, query, or persistence-related code; changes in those areas should receive security-focused review before merge.
- No primary dependency manifest was detected in the repository root. If dependencies are added later, include a manifest and prefer reproducible installation instructions.

## Service and API Notes

For web services, APIs, sockets, or scraping workflows, prioritize reports involving authentication bypass, authorization errors, injection, server-side request forgery, unsafe deserialization, credential leakage, data exposure, or denial-of-service conditions. Use test accounts and minimal proof-of-concept traffic only.

Non-string text cells should fail through `InvalidDataException` before parser
callbacks receive converted values or raw interpreter errors.

Conversion error messages should summarize long, multiline, or unprintable cell
values and escape terminal or log control characters before they reach logs or
caller error handlers.

Target cell type declarations should be validated before opening workbook files
so invalid schemas do not touch parser file resources.
Unsupported date targets are rejected before workbook access.

Target schemas are limited to 256 target columns, and iterable declarations
must be bounded before workbook files are opened.

Workbook paths must resolve to regular `.xls` files no larger than 64 MiB before
opening so unsupported, special-device, or oversized inputs fail before parser
resources are touched. Sheets above 65,536 rows and text cells above 32,767
characters are rejected before callback delivery. Formula evaluation is not
performed; only cached workbook results are read, and incompatible cached values
fail through the row exception path.

An opened workbook with a missing or non-callable release hook must fail before
sheet access or callbacks so completion never claims unperformed cleanup.

Target cell types must be exact integer constants rather than booleans or
numerically equal floats. Sheet names must be non-empty strings and header flags
must be booleans before workbook resources are opened.

Callback slots must be validated before opening workbook files so invalid row,
completion, or exception handlers cannot trigger delayed raw interpreter errors
after parser resources are touched.
Workbook resources are released before a successful parse invokes the
completion callback, so callback code does not run against an open workbook.

GitHub Actions runs clean dependency installs and the local `make check`
baseline on Python 3.10, 3.12, and 3.14 with pinned actions and read-only
repository access. The gate includes `pip-audit` and generates a temporary
synthetic `.xls` workbook to exercise the real parser boundary without
committing spreadsheet data. The workflow does not persist checkout credentials
after source retrieval.
Pinned CodeQL analysis covers GitHub Actions and Python with upload permission
scoped to the analysis job.

The maintained runtime is Python 3.10 or newer. Dormant Python 2 compatibility
branches are excluded from the supported parser path so validation and audit
evidence cover the code that callers actually execute.

## Dependency and Supply Chain Security

Dependency updates should come from trusted package managers and should keep lockfiles in sync when lockfiles exist. Do not commit credentials, private keys, tokens, generated secrets, or machine-local configuration. If a vulnerability depends on a compromised package, typosquatting risk, insecure transitive dependency, or unsafe build step, include the package name, affected version, and the path through which it is used.

## Safe Research Guidelines

Good-faith research is welcome when it stays within these boundaries:

- use only accounts, devices, data, and infrastructure that you own or have explicit permission to test
- avoid destructive actions, persistence, spam, phishing, social engineering, or denial-of-service testing
- minimize access to personal data and stop testing immediately if private data is exposed
- do not exfiltrate secrets or third-party data; report the minimum evidence needed to verify impact
- keep vulnerability details confidential until the maintainer has assessed the report

## Maintainer Response

The maintainer will review complete reports as availability allows, prioritize issues by exploitability and impact, and coordinate a fix or mitigation when the affected code is still maintained. For sample, archived, or educational repositories, the likely remediation may be documentation, dependency updates, or clearly marking unsupported code rather than a production-style patch release.
