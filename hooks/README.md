# Hooks

Claude Code lifecycle hooks for automation and safety guardrails.

## How hooks work

Hooks are shell scripts triggered by Claude Code at specific lifecycle events. They receive a JSON payload via `stdin` and can influence Claude Code's behavior via exit codes and `stdout`.

| Exit code | Meaning |
|---|---|
| `0` | Success – allow the action to proceed |
| `1` | Non-blocking error – show a warning but continue |
| `2` | Blocking error – **abort** the current tool call |

## Available hooks

| Script | Event | Purpose |
|---|---|---|
| `pre-tool/validate-bash.sh` | `PreToolUse` (Bash) | Block dangerous shell commands |
| `post-tool/format-and-lint.sh` | `PostToolUse` (Write/Edit) | Auto-format and lint modified files |
| `notification/desktop-notify.sh` | `Notification` | Desktop notification for Claude alerts |

## Installation

```bash
# Copy to your Claude hooks directory
HOOKS_DIR=~/.claude/hooks
mkdir -p "$HOOKS_DIR/pre-tool" "$HOOKS_DIR/post-tool" "$HOOKS_DIR/notification"
cp pre-tool/*.sh  "$HOOKS_DIR/pre-tool/"
cp post-tool/*.sh "$HOOKS_DIR/post-tool/"
cp notification/*.sh "$HOOKS_DIR/notification/"
chmod +x "$HOOKS_DIR"/**/*.sh
```

Then register them in `~/.claude/settings.json` — see the root README for the full configuration snippet.
