Generate a comprehensive operational runbook for: $ARGUMENTS

The runbook must cover the following sections:

---

## 1. Overview
- **Service / Process name**: (from $ARGUMENTS)
- **Purpose**: what this service does and why it exists.
- **Owner(s)**: team or individual responsible.
- **Criticality**: (Critical / High / Medium / Low) with business impact statement.
- **SLA / SLO**: availability and latency targets.

## 2. Architecture Diagram (text-based)
Provide an ASCII or Mermaid diagram illustrating the service's dependencies, traffic flow, and key components.

## 3. Prerequisites
List tools, access levels, and environment variables required before executing any procedure.

## 4. Deployment Procedure
Step-by-step instructions to deploy a new version, including:
- Pre-deployment checks (health of dependencies, feature flags, db migrations).
- Deployment commands.
- Post-deployment validation steps.
- Rollback procedure if deployment fails.

## 5. Common Operational Tasks
Cover at least five routine tasks (e.g., scaling, config updates, certificate rotation, log retrieval).

## 6. Monitoring & Alerting
- Key metrics to watch (with thresholds).
- Dashboards and alert links.
- On-call escalation path.

## 7. Incident Response
Runbook entries for the top three most likely failure modes, each with:
- **Symptoms** (how you know something is wrong).
- **Diagnosis steps** (commands/queries to confirm).
- **Remediation steps** (ordered, copy-paste ready commands where possible).

## 8. Known Issues & Gotchas
Document recurring quirks, caveats, or tribal knowledge.

## 9. Change Log
| Date | Author | Change |
|------|--------|--------|
| | | |
