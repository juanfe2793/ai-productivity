# Claude Code Hooks

Hooks let you run shell commands automatically when Claude Code events occur.

## How hooks work

Claude Code fires events at key moments in its lifecycle. You register shell commands to run on those events in `~/.claude/settings.json` (global) or `.claude/settings.json` (project-level).

### Available events

| Event              | When it fires                    |
| ------------------ | -------------------------------- |
| `UserPromptSubmit` | Every time you submit a prompt   |
| `Stop`             | When Claude finishes responding  |
| `PreToolUse`       | Before a tool call executes      |
| `PostToolUse`      | After a tool call completes      |
| `Notification`     | When Claude sends a notification |

### settings.json format

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/your/script.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/your/script.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

Hook scripts receive a JSON payload via stdin containing at minimum `session_id`.

## Available hooks

| Name                                                            | Description                                |
| --------------------------------------------------------------- | ------------------------------------------ |
| [long-task-sound-notification](./long-task-sound-notification/) | Plays a sound when a task takes ≥5 minutes |
