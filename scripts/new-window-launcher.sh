#!/usr/bin/env bash
set -euo pipefail

project_dir="${KIRO_PROJECT_DIR:-${PROJECT_ROOT:-$HOME}}"
script_path=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/$(basename -- "${BASH_SOURCE[0]}")

open_shell_window() {
  local target="${1:-}"

  if [[ -n "$target" ]]; then
    tmux new-window -a -t "$target" -c "$project_dir"
  else
    tmux new-window -c "$project_dir"
  fi
}

open_command_window() {
  local target="${1:-}"
  local command="$2"
  local shell_cmd

  shell_cmd=$(printf "%q" "$command; exec bash -i")

  if [[ -n "$target" ]]; then
    tmux new-window -a -t "$target" -c "$project_dir" "bash -ic $shell_cmd"
  else
    tmux new-window -c "$project_dir" "bash -ic $shell_cmd"
  fi
}

show_popup() {
  local target="${1:-}"
  local popup_cmd
  local quoted_script

  quoted_script=$(printf "%q" "$script_path")
  popup_cmd="$quoted_script --popup"

  if [[ -n "$target" ]]; then
    popup_cmd+=" --target $(printf "%q" "$target")"
  fi

  tmux display-popup -E -w 36 -h 7 "$popup_cmd"
}

popup_mode() {
  local target="${1:-}"
  local choice

  printf '\n'
  printf '  New Window\n\n'
  printf '  [K] Kiro CLI\n'
  printf '  [Enter] Shell\n'

  if ! IFS= read -rsn1 choice; then
    open_shell_window "$target"
    return
  fi

  case "$choice" in
    [Kk])
      open_command_window "$target" "kiro-cli"
      ;;
    "")
      open_shell_window "$target"
      ;;
    $'\e' | $'\003')
      return
      ;;
    *)
      open_shell_window "$target"
      ;;
  esac
}

target=""
popup=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --popup)
      popup=true
      shift
      ;;
    --target)
      target="${2:-}"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if [[ "$popup" == true ]]; then
  popup_mode "$target"
else
  show_popup "$target"
fi
