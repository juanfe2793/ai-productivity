#!/usr/bin/env bash
# pre-tool/validate-bash.sh
#
# Claude Code PreToolUse hook — Bash tool safety guardrail.
#
# Purpose:
#   Intercepts every Bash command before Claude Code executes it and blocks
#   commands that match a configurable list of dangerous patterns (e.g. force
#   deletes, recursive privilege changes, disk-wiping utilities).
#
# Event:    PreToolUse
# Matcher:  Bash
#
# Exit codes:
#   0  – command is safe; allow execution.
#   2  – command is dangerous; abort and show reason to the user.
#
# Input (stdin): JSON payload from Claude Code, e.g.:
#   {
#     "tool_name": "Bash",
#     "tool_input": { "command": "rm -rf /" }
#   }

set -euo pipefail

# ---------------------------------------------------------------------------
# Configurable dangerous-command patterns (extended regex)
# Add or remove entries to tune sensitivity for your environment.
# ---------------------------------------------------------------------------
DANGEROUS_PATTERNS=(
    # Recursive force-delete of root, home, or environment-variable paths
    'rm[[:space:]].*-[a-zA-Z]*r[a-zA-Z]*f[[:space:]].*(/|~|\$)'
    'rm[[:space:]].*-[a-zA-Z]*f[a-zA-Z]*r[[:space:]].*(/|~|\$)'
    # Disk-wiping utilities
    '\bdd\b.*of=/dev/(sd|hd|nvme|vd|xvd)'
    '\bmkfs\b'
    '\bshred\b'
    '\bwipefs\b'
    # Recursive chmod/chown on system directories
    'chmod[[:space:]].*-[a-zA-Z]*R[[:space:]].*(/etc|/usr|/bin|/sbin|/boot)'
    'chown[[:space:]].*-[a-zA-Z]*R[[:space:]].*(/etc|/usr|/bin|/sbin|/boot)'
    # Fork bomb  (:() { :|:& };:)
    ':\(\)[[:space:]]*\{[[:space:]]*:[|]'
    # Overwriting critical system files
    '>[[:space:]]*/etc/(passwd|shadow|sudoers|hosts)'
    # Unprotected curl/wget pipe-to-shell
    '(curl|wget)[^|]*\|[[:space:]]*(sudo[[:space:]]+)?(bash|sh|zsh|fish)'
)

# ---------------------------------------------------------------------------
# Read and parse the JSON payload from stdin
# ---------------------------------------------------------------------------
INPUT="$(cat)"
COMMAND="$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null || true)"

if [[ -z "$COMMAND" ]]; then
    # Could not parse command — allow and let Claude Code handle it.
    exit 0
fi

# ---------------------------------------------------------------------------
# Check the command against each dangerous pattern
# ---------------------------------------------------------------------------
for pattern in "${DANGEROUS_PATTERNS[@]}"; do
    if echo "$COMMAND" | grep -Eq "$pattern"; then
        echo "🚫 Blocked by validate-bash hook: command matches dangerous pattern."
        echo "   Pattern : $pattern"
        echo "   Command : $COMMAND"
        echo ""
        echo "If you are sure this command is safe, run it manually in your terminal."
        exit 2
    fi
done

# Command is safe — allow execution.
exit 0
