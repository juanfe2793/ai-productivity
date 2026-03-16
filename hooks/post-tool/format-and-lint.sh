#!/usr/bin/env bash
# post-tool/format-and-lint.sh
#
# Claude Code PostToolUse hook — auto-format and lint after file edits.
#
# Purpose:
#   After Claude Code writes or edits a file, this hook detects the file type
#   and runs the appropriate formatter/linter if it is installed. It never
#   fails hard (exit 0 always) so that a missing formatter does not disrupt
#   the workflow — it just prints an informational message.
#
# Event:    PostToolUse
# Matcher:  Write|Edit|MultiEdit
#
# Exit codes:
#   0  – always; linting errors are reported as warnings, not blockers.
#
# Input (stdin): JSON payload from Claude Code, e.g.:
#   {
#     "tool_name": "Write",
#     "tool_input": { "file_path": "/path/to/file.py" },
#     "tool_response": { ... }
#   }
#
# Dependencies (all optional — hook skips gracefully if not installed):
#   Python  : black, ruff
#   JS/TS   : prettier, eslint
#   Go      : gofmt, golangci-lint
#   Rust    : rustfmt, clippy (via cargo)
#   Shell   : shfmt, shellcheck
#   Terraform: terraform fmt
#   YAML    : yamllint
#   JSON    : python3 (built-in json.tool)

set -uo pipefail

# ---------------------------------------------------------------------------
# Helper: print a prefixed status line
# ---------------------------------------------------------------------------
info()    { echo "ℹ️  [format-and-lint] $*"; }
success() { echo "✅ [format-and-lint] $*"; }
warn()    { echo "⚠️  [format-and-lint] $*"; }

run_if_available() {
    local tool="$1"; shift
    if command -v "$tool" &>/dev/null; then
        "$tool" "$@" && return 0 || return 1
    else
        info "$tool not found — skipping."
        return 0
    fi
}

# ---------------------------------------------------------------------------
# Parse file path from stdin JSON payload
# ---------------------------------------------------------------------------
INPUT="$(cat)"
FILE="$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
ti = d.get('tool_input', {})
print(ti.get('file_path', ti.get('path', '')))
" 2>/dev/null || true)"

if [[ -z "$FILE" || ! -f "$FILE" ]]; then
    info "No valid file path found in payload — nothing to format."
    exit 0
fi

EXT="${FILE##*.}"
info "Processing: $FILE (.$EXT)"

# ---------------------------------------------------------------------------
# Dispatch by file extension
# ---------------------------------------------------------------------------
case "$EXT" in

    py)
        run_if_available black --quiet "$FILE"     && success "black: formatted."
        run_if_available ruff check --fix "$FILE"  && success "ruff: linted."
        ;;

    js|jsx|ts|tsx|mjs|cjs)
        run_if_available prettier --write "$FILE"      && success "prettier: formatted."
        run_if_available eslint --fix --quiet "$FILE"  && success "eslint: linted."
        ;;

    go)
        run_if_available gofmt -w "$FILE"              && success "gofmt: formatted."
        run_if_available golangci-lint run "$FILE"     && success "golangci-lint: linted."
        ;;

    rs)
        run_if_available rustfmt "$FILE"               && success "rustfmt: formatted."
        ;;

    sh|bash|zsh)
        run_if_available shfmt -w "$FILE"              && success "shfmt: formatted."
        run_if_available shellcheck "$FILE"            && success "shellcheck: linted."
        ;;

    tf|tfvars)
        run_if_available terraform fmt "$FILE"         && success "terraform fmt: formatted."
        ;;

    yml|yaml)
        run_if_available yamllint -d relaxed "$FILE"   && success "yamllint: linted."
        ;;

    json)
        # Validate JSON; format in-place with jq if available, otherwise python3
        if command -v jq &>/dev/null; then
            TMP="$(mktemp)"
            if jq . "$FILE" > "$TMP" 2>/dev/null; then
                mv "$TMP" "$FILE"
                success "jq: formatted and validated JSON."
            else
                rm -f "$TMP"
                warn "jq: file contains invalid JSON!"
            fi
        elif python3 -m json.tool "$FILE" > /dev/null 2>&1; then
            success "json: valid JSON (install jq to enable in-place formatting)."
        else
            warn "json: file contains invalid JSON!"
        fi
        ;;

    *)
        info "No formatter configured for .$EXT files."
        ;;
esac

exit 0
