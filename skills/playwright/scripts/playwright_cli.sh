#!/usr/bin/env bash
set -euo pipefail

if ! command -v npx >/dev/null 2>&1; then
  echo "Error: npx is required but not found on PATH." >&2
  exit 1
fi

has_session_flag="false"
has_browser_flag="false"
subcommand=""

args=("$@")
arg_count=${#args[@]}
idx=0

for arg in "${args[@]}"; do
  case "$arg" in
    --session|--session=*)
      has_session_flag="true"
      ;;
    --browser|--browser=*)
      has_browser_flag="true"
      ;;
  esac
done

# Discover the CLI subcommand (first non-option token), accounting for common
# options that take values.
while (( idx < arg_count )); do
  arg="${args[$idx]}"
  case "$arg" in
    --session|--config|--profile|--browser|-s)
      idx=$((idx + 2))
      continue
      ;;
    --session=*|--config=*|--profile=*|--browser=*)
      idx=$((idx + 1))
      continue
      ;;
    --*)
      idx=$((idx + 1))
      continue
      ;;
    *)
      subcommand="$arg"
      break
      ;;
  esac
done

cmd=(npx --yes --package @playwright/cli playwright-cli)
if [[ "${has_session_flag}" != "true" && -n "${PLAYWRIGHT_CLI_SESSION:-}" ]]; then
  cmd+=(--session "${PLAYWRIGHT_CLI_SESSION}")
fi
cmd+=("$@")

# Local default: force Firefox for `open` unless caller explicitly sets browser.
if [[ "${PLAYWRIGHT_CLI_FORCE_FIREFOX:-1}" == "1" && "${subcommand}" == "open" && "${has_browser_flag}" != "true" ]]; then
  cmd+=(--browser firefox)
fi

exec "${cmd[@]}"
