#!/usr/bin/env bash
# notification/desktop-notify.sh
#
# Claude Code Notification hook — desktop notification bridge.
#
# Purpose:
#   Sends a native desktop notification whenever Claude Code fires a
#   Notification event (e.g. when it needs human input, completes a long
#   task, or encounters an error). Useful when Claude is running in the
#   background or in a terminal that is not currently visible.
#
# Event:    Notification
#
# Exit codes:
#   0  – always; notification failures are non-fatal.
#
# Input (stdin): JSON payload from Claude Code, e.g.:
#   {
#     "message": "Claude needs your attention",
#     "title": "Claude Code"
#   }
#
# Platform support:
#   macOS  : osascript (built-in) or terminal-notifier (optional, richer UI)
#   Linux  : notify-send (libnotify), or wall as a fallback
#   WSL    : powershell.exe / wsl-notify-send
#
# Optional: set CLAUDE_NOTIFY_SOUND=1 to play a sound on macOS.

set -uo pipefail

# ---------------------------------------------------------------------------
# Parse the notification payload
# ---------------------------------------------------------------------------
INPUT="$(cat)"

TITLE="$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('title', 'Claude Code'))
" 2>/dev/null || echo "Claude Code")"

MESSAGE="$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('message', 'Claude Code needs your attention.'))
" 2>/dev/null || echo "Claude Code needs your attention.")"

# ---------------------------------------------------------------------------
# Send the notification based on the detected platform
# ---------------------------------------------------------------------------
send_notification() {
    local title="$1"
    local message="$2"

    # macOS
    if [[ "$(uname)" == "Darwin" ]]; then
        if command -v terminal-notifier &>/dev/null; then
            terminal-notifier -title "$title" -message "$message" -sound default 2>/dev/null
        else
            osascript -e "display notification \"$message\" with title \"$title\"" \
                ${CLAUDE_NOTIFY_SOUND:+-e "beep"} 2>/dev/null
        fi
        return
    fi

    # WSL (Windows Subsystem for Linux)
    if grep -qi microsoft /proc/version 2>/dev/null; then
        # Escape single quotes for safe PowerShell string interpolation
        local safe_title="${title//\'/\'\'}"
        local safe_message="${message//\'/\'\'}"
        if command -v wsl-notify-send &>/dev/null; then
            wsl-notify-send --category "$safe_title" "$safe_message" 2>/dev/null
        elif command -v powershell.exe &>/dev/null; then
            powershell.exe -Command "
                Add-Type -AssemblyName System.Windows.Forms
                [System.Windows.Forms.MessageBox]::Show('$safe_message', '$safe_title')
            " 2>/dev/null &
        fi
        return
    fi

    # Linux — prefer notify-send, fall back to wall
    if command -v notify-send &>/dev/null; then
        notify-send --urgency=normal --icon=dialog-information "$title" "$message" 2>/dev/null
    else
        echo -e "\n🔔 $title: $message\n" | wall 2>/dev/null || true
    fi
}

send_notification "$TITLE" "$MESSAGE"
exit 0
