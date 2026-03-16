# Skills (Slash Commands)

Each `.md` file in this directory is a custom Claude Code slash command.

## Installation

```bash
# Install all skills globally (available in every project)
mkdir -p ~/.claude/commands
cp *.md ~/.claude/commands/
```

## Available Skills

| File | Command | Description |
|---|---|---|
| `infra-review.md` | `/infra-review` | Review infrastructure-as-code for best practices and issues |
| `security-audit.md` | `/security-audit` | Run a security posture audit on code or configs |
| `generate-runbook.md` | `/generate-runbook` | Generate an operational runbook for a service or process |
| `code-review.md` | `/code-review` | Structured code review with severity ratings |
