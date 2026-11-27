#!/usr/bin/env bash
set -euo pipefail

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
TIMESTAMP_FILE="/tmp/claude_task_start_${SESSION_ID}"

if [[ ! -f "$TIMESTAMP_FILE" ]]; then
  exit 0
fi

START_TIME=$(cat "$TIMESTAMP_FILE")
NOW=$(date +%s)
ELAPSED=$(( NOW - START_TIME ))
rm -f "$TIMESTAMP_FILE"

if [[ "$ELAPSED" -ge 300 ]]; then
  osascript -e 'display notification "Task complete!" with title "Claude Code" sound name "Glass"' &>/dev/null &
fi

exit 0
