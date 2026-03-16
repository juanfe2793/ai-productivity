# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A curated collection of hooks and skills to increase developer productivity with Claude Code. Contributions are shell scripts or Markdown files — no build system.

## Structure

- `claude-code/hooks/` — shell script hooks triggered by Claude Code lifecycle events
- `claude-code/skills/` — custom slash commands (Markdown files)

## Adding a Hook or Skill

Each hook/skill lives in its own `kebab-case` folder (e.g., `claude-code/hooks/my-hook/`) and must include:
- `README.md` following the template in `CONTRIBUTING.md`
- The script(s) or configuration files

New entries must also be added to the table in the root `README.md`.

## Hook System

Hooks are shell scripts triggered by Claude Code events: `UserPromptSubmit`, `Stop`, `PreToolUse`, `PostToolUse`, `Notification`. They receive a JSON payload via stdin (always includes `session_id`). Use `jq` to parse it.

Hooks are registered in `~/.claude/settings.json`:
```json
{
  "hooks": {
    "EventName": [{ "hooks": [{ "type": "command", "command": "path/to/script.sh" }] }]
  }
}
```

The existing `long-task-sound-notification` hook (macOS-only, requires `jq`) stores state in `/tmp/claude_task_start_<session_id>` and uses `osascript` for notifications.
