# CodeQL Analysis

## Status: Completed

## Context

The hosted Python matrix, dependency audit, and parser contracts are green,
but GitHub reports no code-scanning analysis. Python and workflow changes
therefore lack a first-party static security signal.

## Priority

Add pinned, least-privilege CodeQL analysis to the existing hosted workflow
without changing the maintained runtime or master-only push policy.

## Requirements

- Analyze GitHub Actions and Python on pull requests, master pushes, and manual
  workflow dispatches.
- Keep global workflow permissions read-only and grant
  `security-events: write` only to the CodeQL job.
- Pin CodeQL initialization and analysis to an immutable action SHA.
- Preserve the Python 3.10/3.12/3.14 matrix, dependency audit, and
  credential-free checkout.
- Extend the fail-closed workflow, documentation, suite, and plan contracts.
- Reject hostile mutations for language coverage, upload permission, action
  immutability, and the analysis step.

## Verification

- Shell syntax, workflow YAML parsing, and focused baseline contracts passed.
- The repository and external-directory `make check` passed.
- Four hostile CodeQL workflow mutations were rejected across the language
  matrix, upload permission, immutable action pin, and analysis step.
- Final artifact, credential, exact-diff, and hosted checks remain the shipping
  gate.

## Scope Boundary

This change does not alter parser behavior, callback contracts, workbook
support, dependency versions, or repository-level secret scanning.
