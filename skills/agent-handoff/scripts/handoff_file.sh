#!/usr/bin/env bash
set -euo pipefail

HANDOFF_FILE="${CODEX_HANDOFF_FILE:-/tmp/codex-agent-handoff.md}"

usage() {
  cat <<USAGE
Usage: $(basename "$0") <write|read|pickup|clear|status>

Environment:
  CODEX_HANDOFF_FILE   Override handoff file path (default: /tmp/codex-agent-handoff.md)
USAGE
}

ensure_parent() {
  mkdir -p "$(dirname "$HANDOFF_FILE")"
}

cmd_write() {
  ensure_parent
  local tmp
  tmp="$(mktemp "${HANDOFF_FILE}.tmp.XXXXXX")"
  cat >"$tmp"
  mv "$tmp" "$HANDOFF_FILE"
  echo "WROTE: $HANDOFF_FILE"
}

cmd_read() {
  if [[ ! -f "$HANDOFF_FILE" ]]; then
    echo "MISSING: $HANDOFF_FILE" >&2
    exit 1
  fi
  cat "$HANDOFF_FILE"
}

cmd_pickup() {
  if [[ ! -f "$HANDOFF_FILE" ]]; then
    echo "MISSING: $HANDOFF_FILE" >&2
    exit 1
  fi
  if ! grep -Eiq '^ready:\s*true(\s|$)' "$HANDOFF_FILE"; then
    echo "NOT_READY: missing 'ready: true'" >&2
    exit 2
  fi
  cat "$HANDOFF_FILE"
  : >"$HANDOFF_FILE"
  echo "\nCLEARED: $HANDOFF_FILE" >&2
}

cmd_clear() {
  ensure_parent
  : >"$HANDOFF_FILE"
  echo "CLEARED: $HANDOFF_FILE"
}

cmd_status() {
  if [[ ! -f "$HANDOFF_FILE" ]]; then
    echo "status: missing"
    echo "path: $HANDOFF_FILE"
    exit 0
  fi

  local ready="false"
  if grep -Eiq '^ready:\s*true(\s|$)' "$HANDOFF_FILE"; then
    ready="true"
  fi

  local bytes
  bytes="$(wc -c <"$HANDOFF_FILE" | tr -d ' ')"

  echo "status: present"
  echo "path: $HANDOFF_FILE"
  echo "ready: $ready"
  echo "bytes: $bytes"
}

main() {
  local cmd="${1:-}"
  case "$cmd" in
    write)
      cmd_write
      ;;
    read)
      cmd_read
      ;;
    pickup)
      cmd_pickup
      ;;
    clear)
      cmd_clear
      ;;
    status)
      cmd_status
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

main "${1:-}"
