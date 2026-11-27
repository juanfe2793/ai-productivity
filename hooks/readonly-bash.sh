#!/usr/bin/env bash
# PreToolUse(Bash) guard for read-only subagents. Exit 2 blocks the command.
# A guardrail against accidents, not a security boundary.

cmd=$(jq -r '.tool_input.command // empty')
[ -z "$cmd" ] && exit 0

block() {
  echo "readonly-bash: blocked ($1). This agent is read-only; report what you would run instead." >&2
  exit 2
}

S='[[:space:]]'
deny=(
  "git[^|;&]*${S}(push|commit|merge|rebase|reset|restore|clean|cherry-pick|am|apply|pull|tag|stash)(${S}|\$)"
  "git[^|;&]*${S}branch${S}+-[dDmM]"
  "git[^|;&]*${S}(checkout|switch)${S}+-[bBc]"
  "gh[^|;&]*${S}(pr|issue)${S}+(edit|comment|ready|merge|close|reopen|review|create|lock|unlock)(${S}|\$)"
  "gh[^|;&]*${S}(release|repo|workflow|run|secret|variable)${S}+(create|delete|edit|rename|archive|run|rerun|cancel|set|remove)(${S}|\$)"
  "gh${S}+api[^|;&]*(-X${S}*|--method[ =])(POST|PUT|PATCH|DELETE)"
  "gh${S}+api[^|;&]*--input"
  "(terraform|tofu)${S}+(apply|destroy|import|taint|untaint|force-unlock|state${S}+(rm|mv|push))"
  "kubectl${S}+(apply|create|delete|patch|edit|scale|replace|rollout|drain|cordon|label|annotate)(${S}|\$)"
  "helm${S}+(install|upgrade|uninstall|rollback)(${S}|\$)"
  "aws${S}+s3${S}+(cp|mv|rm|sync|rb|mb)(${S}|\$)"
  "aws[^|;&]*${S}(create|delete|put|update|modify|terminate|run|start|stop|reboot|attach|detach|associate|disassociate|register|deregister|tag|untag|invoke|send|publish|authorize|revoke)-[a-z-]+"
  "curl[^|;&]*(-X${S}*|--request${S}+)(POST|PUT|PATCH|DELETE)"
  "curl[^|;&]*${S}(-d|--data[a-z-]*|-F|--form)(${S}|=)"
  "sed${S}+(-[a-zA-Z]*i|--in-place)"
  "(^|[;&|(]|${S})(mv|truncate|dd|chmod|chown|ln)${S}"
)

for pattern in "${deny[@]}"; do
  if printf '%s' "$cmd" | grep -Eq -- "$pattern"; then
    block "matches /$pattern/"
  fi
done

if printf '%s' "$cmd" | grep -Eq "(^|[;&|(]|${S})rm${S}"; then
  printf '%s' "$cmd" | grep -Eq 'TMPDIR|/tmp/|/var/folders/' || block "rm outside \$TMPDIR"
fi

if printf '%s' "$cmd" | grep -Eq "gh${S}+api[^|;&]*(${S}-[fF]${S}|--(raw-)?field)"; then
  printf '%s' "$cmd" | grep -q 'graphql' || block "gh api with fields implies POST"
fi

while IFS= read -r target; do
  [ -z "$target" ] && continue
  case "$target" in
    /dev/null|/tmp/*|/private/tmp/*|/var/folders/*|/private/var/folders/*) ;;
    '$TMPDIR'*|'${TMPDIR'*|[0-9=]*) ;;
    *) block "write redirect to $target" ;;
  esac
done < <(printf '%s' "$cmd" | grep -oE '(^|[^&>=-])>>?[[:space:]]*[^[:space:]&|;>]+' | sed -E "s/^[^>]*>>?[[:space:]]*//; s/^[\"']//")

exit 0
