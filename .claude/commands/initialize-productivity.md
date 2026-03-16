Install hooks and skills from this productivity repo into the user's global Claude Code config (`~/.claude/`).

## Instructions

Run the following steps using bash commands. Do not ask for confirmation — execute each step directly.

### Step 1: Determine repo root

```bash
REPO_ROOT=$(git -C "$(dirname "$(realpath ~/.claude/commands/initialize-productivity.md 2>/dev/null || echo .)")" rev-parse --show-toplevel 2>/dev/null || git rev-parse --show-toplevel)
```

### Step 2: Parse arguments

`$ARGUMENTS` may be empty, or contain comma/whitespace-separated component names.

```bash
# Discover available components
AVAILABLE_HOOKS=$(ls "$REPO_ROOT/claude-code/hooks/" | grep -v README.md | grep -v '^$' || true)
AVAILABLE_SKILLS=$(ls "$REPO_ROOT/claude-code/skills/" | grep -v README.md | grep '\.md$' | sed 's/\.md$//' || true)

# Parse requested names from $ARGUMENTS
if [ -z "$ARGUMENTS" ]; then
  REQUESTED_HOOKS="$AVAILABLE_HOOKS"
  REQUESTED_SKILLS="$AVAILABLE_SKILLS"
else
  # Split on commas and whitespace
  REQUESTED=$(echo "$ARGUMENTS" | tr ',\t' '  ' | tr -s ' ' '\n' | grep -v '^$')
  REQUESTED_HOOKS=""
  REQUESTED_SKILLS=""
  UNKNOWN=""
  while IFS= read -r name; do
    if echo "$AVAILABLE_HOOKS" | grep -qx "$name"; then
      REQUESTED_HOOKS="$REQUESTED_HOOKS $name"
    elif echo "$AVAILABLE_SKILLS" | grep -qx "$name"; then
      REQUESTED_SKILLS="$REQUESTED_SKILLS $name"
    else
      UNKNOWN="$UNKNOWN $name"
    fi
  done <<< "$REQUESTED"
fi
```

### Step 3: Install hooks

For each hook in `$REQUESTED_HOOKS`:

```bash
mkdir -p ~/.claude/hooks

for hook in $REQUESTED_HOOKS; do
  HOOK_DIR="$REPO_ROOT/claude-code/hooks/$hook"
  SCRIPTS=$(find "$HOOK_DIR" -name "*.sh" 2>/dev/null)

  # Check if already installed (all scripts present)
  ALL_PRESENT=true
  for script in $SCRIPTS; do
    dest="$HOME/.claude/hooks/$(basename "$script")"
    [ -f "$dest" ] || ALL_PRESENT=false
  done

  if $ALL_PRESENT && [ -n "$SCRIPTS" ]; then
    echo "Hook '$hook': scripts already present (will still verify settings.json)"
  else
    for script in $SCRIPTS; do
      cp "$script" ~/.claude/hooks/
      chmod +x "$HOME/.claude/hooks/$(basename "$script")"
    done
    echo "Hook '$hook': scripts copied"
  fi
done
```

### Step 4: Install skills

```bash
mkdir -p ~/.claude/skills

for skill in $REQUESTED_SKILLS; do
  src="$REPO_ROOT/claude-code/skills/$skill.md"
  dest="$HOME/.claude/skills/$skill.md"
  if [ -f "$dest" ]; then
    echo "Skill '$skill': already installed"
  else
    cp "$src" "$dest"
    echo "Skill '$skill': installed"
  fi
done
```

### Step 5: Merge hook registrations into settings.json

Run this python3 script to safely merge without destroying existing config:

```bash
REQUESTED_HOOKS="$REQUESTED_HOOKS" python3 << 'PYEOF'
import json, os, sys

settings_path = os.path.expanduser("~/.claude/settings.json")

# Read existing settings
if os.path.exists(settings_path):
    with open(settings_path) as f:
        try:
            settings = json.load(f)
        except json.JSONDecodeError:
            settings = {}
else:
    settings = {}

if "hooks" not in settings:
    settings["hooks"] = {}

# New registrations to merge
new_hooks = {
    "UserPromptSubmit": [{"hooks": [{"type": "command", "command": "~/.claude/hooks/record_start_time.sh", "timeout": 5}]}],
    "Stop":             [{"hooks": [{"type": "command", "command": "~/.claude/hooks/notify_if_long_task.sh", "timeout": 10}]}]
}

# Check which hooks are being requested (passed via env or we merge all for simplicity)
import sys
requested_hooks_env = os.environ.get("REQUESTED_HOOKS", "").split()

# Only merge registrations for hooks that are being installed
hooks_to_register = {}
if not requested_hooks_env or "long-task-sound-notification" in requested_hooks_env:
    hooks_to_register.update(new_hooks)

updated = False
already_present = []

for event, entries in hooks_to_register.items():
    for entry in entries:
        for hook_obj in entry.get("hooks", []):
            cmd = hook_obj.get("command")
            # Check if this command is already registered
            existing_event = settings["hooks"].get(event, [])
            found = False
            for existing_entry in existing_event:
                for existing_hook in existing_entry.get("hooks", []):
                    if existing_hook.get("command") == cmd:
                        found = True
                        break
                if found:
                    break
            if found:
                already_present.append(f"{event}: {cmd}")
            else:
                if event not in settings["hooks"]:
                    settings["hooks"][event] = []
                settings["hooks"][event].extend(entries)
                updated = True
                print(f"settings.json: added {event} → {cmd}")
                break  # avoid duplicating the whole entry block

for item in already_present:
    print(f"settings.json: already present — {item}")

if updated:
    with open(settings_path, "w") as f:
        json.dump(settings, f, indent=2)
    print("settings.json: saved")
PYEOF
```

### Step 6: Print summary

```bash
echo ""
echo "=== Installation complete ==="
[ -n "$REQUESTED_HOOKS" ] && echo "Hooks processed: $REQUESTED_HOOKS"
[ -n "$REQUESTED_SKILLS" ] && echo "Skills processed: $REQUESTED_SKILLS"
[ -z "$REQUESTED_HOOKS" ] && [ -z "$REQUESTED_SKILLS" ] && echo "Nothing to install."
for u in $UNKNOWN; do
  echo "WARNING: '$u' did not match any known hook or skill"
done
```

> Note: The python3 merge step only registers `long-task-sound-notification` entries when that hook is in the requested list. If new hooks are added to the repo in the future, update Step 5 accordingly.
