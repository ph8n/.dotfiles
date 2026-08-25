#!/bin/zsh

set -eu

readonly profile_bin="/etc/profiles/per-user/$USER/bin"
readonly yabai_bin="$profile_bin/yabai"
readonly jq_bin="$profile_bin/jq"

if ! windows_json="$($yabai_bin -m query --windows 2>/dev/null)"; then
  $jq_bin -cn '{items: [{title: "Unable to query yabai", subtitle: "Check that yabai is running", valid: false}]}'
  exit 0
fi

app_icons='{}'
window_pids=("${(@f)$(print -r -- "$windows_json" | $jq_bin -r '[.[].pid] | unique[]')}")

for window_pid in "${window_pids[@]}"; do
  [[ -n "$window_pid" ]] || continue

  process_path="$(/bin/ps -p "$window_pid" -o command= 2>/dev/null)"
  app_path="${process_path%/Contents/*}"
  [[ "$app_path" == *.app && -d "$app_path" ]] || continue

  app_icons="$(
    print -r -- "$app_icons" \
      | $jq_bin -c --arg pid "$window_pid" --arg path "$app_path" '. + {($pid): $path}'
  )"
done

print -r -- "$windows_json" | $jq_bin -c --argjson app_icons "$app_icons" '
  [
    .[]
    | select(."has-ax-reference" == true)
    | select(.role == "AXWindow")
    | select(.subrole == "AXStandardWindow" or .subrole == "AXDialog")
  ]
  | sort_by(.app)
  | group_by(.app)
  | {
      items: map(
        . as $windows
        | ($windows
           | sort_by(
               if ."has-focus" then 0
               elif (.subrole == "AXStandardWindow" and ."is-visible" and (."is-minimized" | not)) then 1
               elif .subrole == "AXStandardWindow" then 2
               else 3
               end
             )
           | .[0]) as $window
        | ($app_icons[$window.pid | tostring] // "") as $icon_path
        | {
            uid: ("yabai-app-" + ($window.pid | tostring)),
            title: $window.app,
            subtitle: (
              (if ($window.title | length) > 0 then $window.title else "Untitled window" end)
              + "  ·  Space " + ($window.space | tostring)
              + (if ($windows | length) > 1
                 then "  ·  " + (($windows | length) | tostring) + " windows"
                 else ""
                 end)
              + (if $window."is-minimized" then "  ·  Minimized"
                 elif $window."is-hidden" then "  ·  Hidden"
                 elif $window."is-floating" then "  ·  Floating"
                 else ""
                 end)
            ),
            arg: ($window.id | tostring),
            match: ($window.app + " " + ($windows | map(.title) | join(" "))),
            autocomplete: $window.app,
            valid: true
          }
          + (if ($icon_path | length) > 0
             then {icon: {type: "fileicon", path: $icon_path}}
             else {}
             end)
      )
      | sort_by(.title | ascii_downcase)
    }
'
