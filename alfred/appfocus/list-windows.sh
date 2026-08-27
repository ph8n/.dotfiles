#!/bin/zsh

set -eu

readonly profile_bin="/etc/profiles/per-user/$USER/bin"
readonly yabai_bin="$profile_bin/yabai"
readonly jq_bin="$profile_bin/jq"

if ! visible_asns="$(/usr/bin/lsappinfo -nonames visibleProcessList 2>/dev/null)"; then
  $jq_bin -cn '{items: [{title: "Unable to query running apps", subtitle: "LaunchServices did not respond", valid: false}]}'
  exit 0
fi

# Build one record for every visible foreground app. LaunchServices includes
# apps without a yabai window (such as Finder or Mail), which a window-only
# query would otherwise omit.
app_records=()
for app_asn in ${=visible_asns}; do
  app_info="$(/usr/bin/lsappinfo info "$app_asn" 2>/dev/null)" || continue
  info_lines=("${(@f)app_info}")
  [[ ${#info_lines[@]} -gt 0 ]] || continue

  first_line="$info_lines[1]"
  app_name="${first_line#\"}"
  app_name="${app_name%%\" ASN:*}"
  bundle_id=""
  app_path=""
  app_pid=""

  for line in "${info_lines[@]}"; do
    case "$line" in
      *'bundleID="'*)
        bundle_id="${line#*bundleID=\"}"
        bundle_id="${bundle_id%%\"*}"
        ;;
      *'bundle path="'*)
        app_path="${line#*bundle path=\"}"
        app_path="${app_path%%\"*}"
        ;;
      *'pid = '*)
        app_pid="${line#*pid = }"
        app_pid="${app_pid%% *}"
        ;;
    esac
  done

  [[ -n "$app_name" && -n "$bundle_id" && "$app_pid" == <-> ]] || continue
  [[ "$app_path" == *.app && -d "$app_path" ]] || continue
  app_records+=("$app_pid"$'\t'"$app_name"$'\t'"$bundle_id"$'\t'"$app_path")
done

apps_json="$(
  printf '%s\n' "${app_records[@]}" | $jq_bin -Rsc '
    split("\n")
    | map(select(length > 0) | split("\t"))
    | map(select(length >= 4) | {
        pid: (.[0] | tonumber),
        name: .[1],
        bundle_id: .[2],
        path: .[3]
      })
  '
)"

# Window data enriches subtitles and searching, but the app list remains useful
# when yabai is unavailable or an app currently has no standard window.
windows_json="$($yabai_bin -m query --windows 2>/dev/null || print -r -- '[]')"

$jq_bin -cn --argjson apps "$apps_json" --argjson windows "$windows_json" '
  {
    items: [
      $apps[]
      | . as $app
      | ([$windows[]
          | select(.pid == $app.pid)
          | select(."has-ax-reference" == true)
          | select(.role == "AXWindow")
          | select(.subrole == "AXStandardWindow" or .subrole == "AXDialog")
        ]) as $app_windows
      | ($app_windows
         | sort_by(
             if ."has-focus" then 0
             elif (.subrole == "AXStandardWindow" and ."is-visible" and (."is-minimized" | not)) then 1
             elif .subrole == "AXStandardWindow" then 2
             else 3
             end
           )
         | .[0] // null) as $window
      | {
          title: $app.name,
          subtitle: (
            if $window == null then $app.path
            else
              (if ($window.title | length) > 0 then $window.title else "Untitled window" end)
              + "  ·  Space " + ($window.space | tostring)
              + (if ($app_windows | length) > 1
                 then "  ·  " + (($app_windows | length) | tostring) + " windows"
                 else ""
                 end)
              + (if $window."is-minimized" then "  ·  Minimized"
                 elif $window."is-hidden" then "  ·  Hidden"
                 elif $window."is-floating" then "  ·  Floating"
                 else ""
                 end)
            end
          ),
          arg: $app.bundle_id,
          match: ($app.name + " " + ($app_windows | map(.title) | join(" "))),
          autocomplete: $app.name,
          valid: true,
          icon: {type: "fileicon", path: $app.path}
        }
    ]
    # No item UID: Alfred must preserve this exact alphabetical order instead
    # of applying its learned, recently-used ranking.
    | sort_by(.title | ascii_downcase)
  }
'
