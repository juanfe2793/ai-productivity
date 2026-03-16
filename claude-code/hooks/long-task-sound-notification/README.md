# long-task-sound-notification

Plays a macOS sound notification when Claude Code finishes a task that took 5 minutes or longer — useful when you step away during long-running tasks.

## How it works

Two hooks work together:

1. **`record_start_time.sh`** — fires on `UserPromptSubmit`, writes the current Unix timestamp to a temp file keyed by session ID
2. **`notify_if_long_task.sh`** — fires on `Stop`, reads the start time, computes elapsed time, and triggers a macOS notification with a sound if ≥5 minutes have passed

## Requirements

- macOS (uses `osascript` for notifications)
- [`jq`](https://jqlang.github.io/jq/) — for parsing the hook JSON payload (`brew install jq`)
- Claude Code

## Installation

1. Copy both scripts to `~/.claude/hooks/`:

```bash
cp record_start_time.sh ~/.claude/hooks/
cp notify_if_long_task.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/record_start_time.sh ~/.claude/hooks/notify_if_long_task.sh
```

2. Add the following to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/Users/YOUR_USERNAME/.claude/hooks/record_start_time.sh",
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
            "command": "/Users/YOUR_USERNAME/.claude/hooks/notify_if_long_task.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

Replace `YOUR_USERNAME` with your macOS username (`whoami` in terminal).

## Configuration

**Change the threshold** — edit `notify_if_long_task.sh` and update:

```bash
if [[ "$ELAPSED" -ge 300 ]]; then
```

`300` = 5 minutes. Change to `60` for 1 minute, `600` for 10 minutes, etc.

**Change the sound** — replace `"Glass"` in `notify_if_long_task.sh` with any macOS system sound:

- `"Ping"`, `"Purr"`, `"Sosumi"`, `"Hero"`, `"Basso"`, `"Blow"`, `"Bottle"`, `"Frog"`, `"Funk"`, `"Morse"`, `"Pop"`, `"Submarine"`, `"Tink"`
