#!/usr/bin/env bash
# Runs `./mvnw verify` at the end of an agent turn, if code changed. Shared by the agent hooks:
#   Claude Code: Stop hook in .claude/settings.json  -> scripts/verify.sh claude
#   Mistral Vibe: post_agent hook in .vibe/hooks.toml -> scripts/verify.sh vibe
# On failure it hands the end of the build log back to the agent, so it fixes it before finishing.
set -u
mode="${1:-}"
input="$(cat)" # hook payload (JSON) on stdin

cd "$(dirname "$0")/.." || exit 0

# Only uncommitted changes to code or build files trigger the tests; a chat-only turn stays fast.
if [ -z "$(git status --porcelain -- src pom.xml mvnw .mvn 2>/dev/null)" ]; then
  exit 0
fi

# Claude Code: if this turn is already a retry after a failure, let the agent stop (no loops).
# (Vibe caps retries by itself at 3 per turn.)
if [ "$mode" = claude ] && printf '%s' "$input" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then
  exit 0
fi

log="$(./mvnw -B -q verify 2>&1)" && exit 0

reason="./mvnw verify failed. Fix the build or tests before finishing (or explain why not). Last lines:
$(printf '%s\n' "$log" | tail -n 40)"

case "$mode" in
  claude)
    printf '%s\n' "$reason" >&2
    exit 2 # blocks the stop; stderr goes to Claude
    ;;
  vibe)
    # JSON response: decision "deny" sends the reason back to the agent as a new message.
    escaped="$(printf '%s' "$reason" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\t/\\t/g' -e 's/\r//g' | awk '{printf "%s\\n", $0}')"
    printf '{"decision": "deny", "reason": "%s"}\n' "$escaped"
    exit 0
    ;;
  *)
    printf '%s\n' "$reason" >&2
    exit 1
    ;;
esac
