# BUG_FIX Workflow

1. Codex converts the user symptom into a reproducible claim.
2. Search project memory for confirmed, rejected, obsolete, and version-specific solutions.
3. Delegate ordinary defects to `oc-autofix`.
4. Use a debugger first for intermittent, complex, or repeated failures.
5. Require an independent review for non-trivial changes.
6. Verify the original reproduction and regression test independently.
7. If verification fails, return exact command, exit status, output, and behavior for one narrower repair task.
8. Codex assigns final status and writes verified lessons back to memory.
