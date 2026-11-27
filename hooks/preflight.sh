#!/usr/bin/env bash
# SessionStart preflight: prints WARN lines (added to session context) for stale auth. Never blocks.

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

if [ -n "${GITHUB_TOKEN:-}" ]; then
  (gh auth status --hostname github.com >/dev/null 2>&1 || echo "WARN: GITHUB_TOKEN is set but invalid for github.com. Run: unset GITHUB_TOKEN" >"$tmp/token") &
fi

(env -u GITHUB_TOKEN gh auth status --hostname github.com >/dev/null 2>&1 || echo "WARN: gh has no saved login for github.com. Run: gh auth login --hostname github.com" >"$tmp/gh") &

(aws sts get-caller-identity --cli-connect-timeout 3 --cli-read-timeout 3 >/dev/null 2>&1 || echo "WARN: AWS credentials invalid or SSO expired (profile: ${AWS_PROFILE:-default}). Run: aws sso login" >"$tmp/aws") &

wait
cat "$tmp"/* 2>/dev/null
exit 0
