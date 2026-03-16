Perform a thorough security audit on the code, configuration files, or directory specified in $ARGUMENTS (default: the entire project).

Audit the following dimensions:

1. **Secrets & Credentials** – hardcoded passwords, API keys, tokens, private keys, or connection strings in source code or configs.
2. **Authentication & Authorization** – missing auth checks, broken access control, privilege escalation paths, insecure defaults.
3. **Injection vulnerabilities** – SQL injection, command injection, path traversal, template injection, SSRF.
4. **Dependency vulnerabilities** – outdated or known-vulnerable packages (check lock files and manifests).
5. **Cryptography** – weak algorithms (MD5, SHA1, DES), hardcoded IVs/salts, insecure random number generation.
6. **Network exposure** – overly permissive firewall rules, publicly exposed management interfaces, unencrypted traffic.
7. **Logging & Monitoring gaps** – sensitive data logged in plaintext, missing audit trails for privileged actions.
8. **Infrastructure misconfigurations** – world-readable S3 buckets, permissive IAM/RBAC, missing encryption at rest or in transit.

For each finding:
- **File / location** (with line numbers where possible).
- **Severity**: 🔴 Critical | 🟠 High | 🟡 Medium | 🟢 Low.
- **Description**: what the vulnerability is and what an attacker could do.
- **Remediation**: specific, actionable steps or code fix.

End with an **Executive Summary** (3-5 sentences) and a findings table grouped by severity.

Scope: $ARGUMENTS
