#!/usr/bin/env bash
set -euo pipefail

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
date +%s > "/tmp/claude_task_start_${SESSION_ID}"
exit 0
