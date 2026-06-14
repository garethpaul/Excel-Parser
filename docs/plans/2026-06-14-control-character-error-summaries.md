---
title: Control Character Error Summaries
type: security
date: 2026-06-14
status: in-progress
execution: code
---

# Control Character Error Summaries

## Summary

Prevent untrusted workbook cell values from carrying terminal and log control
characters through conversion-error summaries. Preserve readable printable
content while escaping non-printable characters within the existing bounded
error-value contract.

## Prioritized Engineering Tasks

1. Escape non-printable characters after existing line-boundary normalization.
2. Apply the existing length budget to the escaped representation so emitted
   summaries remain bounded.
3. Add executable and static contracts for ESC, NUL, tab, printable Unicode,
   and post-escape truncation behavior.
4. Document the hardened diagnostic boundary in contributor and security
   guidance.

## Requirements

- R1. Error summaries must not contain raw non-printable characters.
- R2. Existing CR/LF normalization must continue to produce readable spaces.
- R3. Printable ASCII and Unicode content must remain unchanged.
- R4. Escaped summaries must remain bounded by the existing error-value limit
  plus the established truncation marker.
- R5. Parser callback signatures and successful conversion behavior must not
  change.

## Non-Goals

- Redacting printable workbook content beyond the existing length limit.
- Changing conversion rules, row callback behavior, or workbook lifecycle.
- Adding a logging framework or third-party sanitization dependency.

## Verification

- Pending implementation and bounded validation.
