# ai-productivity

A curated collection of hooks and skills to increase developer productivity with AI coding tools. Primarily focused on Software Infrastructure Engineers.

## What's Here

| Tool        | Type | Name                                                                              | Description                                                    |
| ----------- | ---- | --------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| Claude Code | Hook | [long-task-sound-notification](./claude-code/hooks/long-task-sound-notification/) | Plays a sound when Claude finishes a task that took ≥5 minutes |

# personal-agents

Generic Claude Code subagents. No employer-specific hosts, products or plugins.

| Agent             | Model  | Role                                                              |
| ----------------- | ------ | ----------------------------------------------------------------- |
| `coder`           | opus   | Implements one scoped change with tests. Never commits or pushes. |
| `reviewer`        | sonnet | Read-only single-pass code review.                                |
| `qa`              | sonnet | Read-only check of requirements, MET / NOT MET / UNVERIFIED.      |
| `ci-checker`      | sonnet | Read-only gate: checks green on the head SHA and PR mergeable.    |
| `deploy-verifier` | sonnet | Read-only post-merge check of pipeline run and cloud resources.   |

## Install

```bash
mkdir -p ~/.claude/agents ~/.claude/hooks
cp agents/*.md ~/.claude/agents/
cp hooks/*.sh ~/.claude/hooks/ && chmod +x ~/.claude/hooks/*.sh
```

Optional preflight (warns about a stale `GITHUB_TOKEN`, missing gh login, expired AWS credentials). Add to `~/.claude/settings.json`:

```json
"hooks": { "SessionStart": [{ "hooks": [{ "type": "command", "command": "$HOME/.claude/hooks/preflight.sh" }] }] }
```

Requires `jq`, `gh` and `aws`.

## Notes

- Read-only agents have no Edit/Write; `hooks/readonly-bash.sh` blocks mutating shell commands. It is a guardrail, not a security boundary.
- Subagents cannot run workflows or `ultracode`; use those from the main session.

## Quick Start

Browse by tool:

- [Claude Code](./claude-code/README.md) — hooks and skills for the Claude Code CLI

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for how to add a hook or skill.

## License

MIT — see [LICENSE](./LICENSE).
