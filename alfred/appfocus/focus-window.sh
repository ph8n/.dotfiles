#!/bin/zsh

set -u

readonly profile_bin="/etc/profiles/per-user/$USER/bin"
readonly yabai_bin="$profile_bin/yabai"
readonly jq_bin="$profile_bin/jq"
readonly bundle_id="${1:-}"

if [[ -z "$bundle_id" ]]; then
  exit 2
fi

app_asn="$(/usr/bin/lsappinfo find bundleID="$bundle_id" 2>/dev/null)"
pid_output="$(/usr/bin/lsappinfo info -only pid "$app_asn" 2>/dev/null)"
app_pid="${pid_output#*=}"
app_pid="${app_pid//[^0-9]/}"

if [[ ! "$app_pid" =~ '^[0-9]+$' ]]; then
  /usr/bin/open -b "$bundle_id" >/dev/null 2>&1
  exit $?
fi

if ! windows_json="$($yabai_bin -m query --windows 2>/dev/null)"; then
  /usr/bin/open -b "$bundle_id" >/dev/null 2>&1
  exit $?
fi

window_json="$(
  print -r -- "$windows_json" | $jq_bin -c --argjson pid "$app_pid" '
    [
      .[]
      | select(.pid == $pid)
      | select(."has-ax-reference" == true)
      | select(.role == "AXWindow")
      | select(.subrole == "AXStandardWindow" or .subrole == "AXDialog")
    ]
    | sort_by(
        if ."has-focus" then 0
        elif (.subrole == "AXStandardWindow" and ."is-visible" and (."is-minimized" | not)) then 1
        elif .subrole == "AXStandardWindow" then 2
        elif (."is-visible" and (."is-minimized" | not)) then 3
        else 4
        end
      )
    | .[0] // empty
  '
)"

if [[ -z "$window_json" ]]; then
  /usr/bin/open -b "$bundle_id" >/dev/null 2>&1
  exit $?
fi

window_id="$(print -r -- "$window_json" | $jq_bin -r '.id')"

if [[ "$(print -r -- "$window_json" | $jq_bin -r '."is-minimized"')" == "true" ]]; then
  $yabai_bin -m window "$window_id" --deminimize >/dev/null 2>&1 || true
fi

if $yabai_bin -m window --focus "$window_id" >/dev/null 2>&1 \
  && $yabai_bin -m query --windows \
    | $jq_bin -e --argjson pid "$app_pid" 'any(.[]; .pid == $pid and ."has-focus")' >/dev/null; then
  exit 0
fi

window_space="$(print -r -- "$window_json" | $jq_bin -r '.space')"
$yabai_bin -m space --focus "$window_space" >/dev/null 2>&1 || true
$yabai_bin -m window --focus "$window_id" >/dev/null 2>&1 || true
$yabai_bin -m query --windows \
  | $jq_bin -e --argjson pid "$app_pid" 'any(.[]; .pid == $pid and ."has-focus")' >/dev/null \
  || /usr/bin/open -b "$bundle_id" >/dev/null 2>&1
