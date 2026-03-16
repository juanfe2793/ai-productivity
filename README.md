# ai-productivity

A curated collection of **Claude Code Skills** (slash commands) and **Hooks** to supercharge the development workflow for Software Infrastructure Engineers.

---

## 📁 Repository Structure

```
ai-productivity/
├── skills/          # Custom Claude Code slash commands (/commands)
│   ├── infra-review.md
│   ├── security-audit.md
│   ├── generate-runbook.md
│   └── code-review.md
└── hooks/           # Claude Code lifecycle hook scripts
    ├── pre-tool/
    │   └── validate-bash.sh
    ├── post-tool/
    │   └── format-and-lint.sh
    └── notification/
        └── desktop-notify.sh
```

---

## 🧠 Skills (Slash Commands)

Skills are custom Claude Code slash commands stored as Markdown files. Place them in:

- **Global** (all projects): `~/.claude/commands/`
- **Project-specific**: `.claude/commands/` inside your project root

Once installed, invoke a skill with `/skill-name` or `/skill-name <arguments>` inside Claude Code.

| Skill | Command | Description |
|---|---|---|
| Infrastructure Review | `/infra-review` | Deep review of infrastructure-as-code files (Terraform, Ansible, K8s) |
| Security Audit | `/security-audit` | Security posture audit with actionable findings |
| Generate Runbook | `/generate-runbook <service>` | Auto-generate deployment/operations runbook for a service |
| Code Review | `/code-review` | Structured code review with severity ratings |

### Installation

```bash
# Install all skills globally
mkdir -p ~/.claude/commands
cp skills/*.md ~/.claude/commands/
```

---

## 🪝 Hooks

Hooks are shell scripts that Claude Code executes at specific lifecycle events. They are configured via `settings.json`.

Place scripts in a directory of your choice (e.g., `~/.claude/hooks/`) and reference them in your Claude Code settings.

| Hook | Event | Description |
|---|---|---|
| `validate-bash.sh` | `PreToolUse` | Blocks dangerous shell commands before execution |
| `format-and-lint.sh` | `PostToolUse` | Auto-formats and lints files after edits |
| `desktop-notify.sh` | `Notification` | Sends desktop notifications for Claude Code alerts |

### Installation

```bash
# Copy hooks to your hooks directory
mkdir -p ~/.claude/hooks/pre-tool ~/.claude/hooks/post-tool ~/.claude/hooks/notification
cp hooks/pre-tool/*.sh ~/.claude/hooks/pre-tool/
cp hooks/post-tool/*.sh ~/.claude/hooks/post-tool/
cp hooks/notification/*.sh ~/.claude/hooks/notification/
chmod +x ~/.claude/hooks/**/*.sh
```

Then add the following to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/pre-tool/validate-bash.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/post-tool/format-and-lint.sh"
          }
        ]
      }
    ],
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/notification/desktop-notify.sh"
          }
        ]
      }
    ]
  }
}
```

---

## 🤝 Contributing

Feel free to open a PR with your own skills and hooks. Keep each file focused on a single responsibility and include a header comment explaining what it does and how to use it.

---

## 📚 References

- [Claude Code Hooks Documentation](https://docs.anthropic.com/en/docs/claude-code/hooks)
- [Claude Code Slash Commands](https://docs.anthropic.com/en/docs/claude-code/slash-commands)
