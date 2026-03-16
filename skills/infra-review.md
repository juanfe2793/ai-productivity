Review the infrastructure-as-code files in the current project (or the file/directory specified in $ARGUMENTS) for:

1. **Security issues** – hardcoded secrets, overly permissive IAM/RBAC policies, open security groups, unencrypted storage, public exposure of sensitive resources.
2. **Reliability & resiliency** – single points of failure, missing health checks, lack of redundancy, improper auto-scaling settings.
3. **Cost optimization** – over-provisioned resources, unused assets, missing lifecycle policies, opportunities to use reserved or spot instances.
4. **Operational best practices** – missing tags, lack of logging/monitoring, no alerting configured, drift detection disabled.
5. **IaC quality** – hardcoded values that should be variables, missing descriptions/comments, module reuse opportunities, deprecated syntax.

For each finding:
- State the **file and line** (if applicable).
- Rate the **severity**: 🔴 Critical | 🟠 High | 🟡 Medium | 🟢 Low | ℹ️ Informational.
- Provide a **clear explanation** of the issue and its impact.
- Give a **concrete fix** or code snippet.

Conclude with a brief **summary scorecard** showing the count of findings per severity level.

Target: $ARGUMENTS
