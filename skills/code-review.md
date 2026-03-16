Review the code changes in $ARGUMENTS (if empty, review the current git diff or recently modified files) and provide structured feedback.

Structure your review as follows:

### Summary
A 2-3 sentence overview of what the change does and your overall impression.

### Findings

For each issue found, use this format:

**[SEVERITY] Short title**
- **Location**: file:line
- **Issue**: clear description of the problem.
- **Suggestion**: concrete fix or improved code snippet.

Severity levels:
- 🔴 **Blocker** – must be fixed before merging (correctness, security, data loss risk).
- 🟠 **Major** – significant quality issue that should be addressed.
- 🟡 **Minor** – small improvement; nice-to-have.
- 🟢 **Nit** – style or convention inconsistency; low priority.
- ✅ **Praise** – something done particularly well.

### Checklist

Before approving, confirm:
- [ ] Logic is correct and edge cases are handled.
- [ ] No hardcoded secrets or sensitive data.
- [ ] Error handling is appropriate.
- [ ] Tests cover the new behavior (unit and/or integration).
- [ ] Documentation / comments are updated.
- [ ] No breaking changes to public APIs (or they are intentional and documented).
- [ ] Performance implications have been considered.

### Verdict
**Approve** / **Request Changes** / **Needs Discussion** – with one-line rationale.

Target: $ARGUMENTS
