# #!/bin/bash
#
# [[ -f ~/.config/user-dirs.dirs ]] && source ~/.config/user-dirs.dirs
# OUTPUT_DIR="${OMARCHY_SCREENSHOT_DIR:-${XDG_PICTURES_DIR:-$HOME/Pictures}}"
#
# if [[ ! -d "$OUTPUT_DIR" ]]; then
#   notify-send "Screenshot directory does not exist: $OUTPUT_DIR" -u critical -t 3000
#   exit 1
# fi
#
# pkill slurp && exit 0
#
# MODE="${1:-smart}"
# PROCESSING="${2:-slurp}"
#
# get_rectangles() {
#   local active_workspace=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .activeWorkspace.id')
#   hyprctl monitors -j | jq -r --arg ws "$active_workspace" '.[] | select(.activeWorkspace.id == ($ws | tonumber)) | "\(.x),\(.y) \((.width / .scale) | floor)x\((.height / .scale) | floor)"'
#   hyprctl clients -j | jq -r --arg ws "$active_workspace" '.[] | select(.workspace.id == ($ws | tonumber)) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"'
# }
#
# # Select based on mode
# case "$MODE" in
#   region)
#     wayfreeze & PID=$!
#     sleep .1
#     SELECTION=$(slurp 2>/dev/null)
#     kill $PID 2>/dev/null
#     ;;
#   windows)
#     wayfreeze & PID=$!
#     sleep .1
#     SELECTION=$(get_rectangles | slurp -r 2>/dev/null)
#     kill $PID 2>/dev/null
#     ;;
#   fullscreen)
#     SELECTION=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | "\(.x),\(.y) \((.width / .scale) | floor)x\((.height / .scale) | floor)"')
#     ;;
#   smart|*)
#     RECTS=$(get_rectangles)
#     wayfreeze & PID=$!
#     sleep .1
#     SELECTION=$(echo "$RECTS" | slurp 2>/dev/null)
#     kill $PID 2>/dev/null
#
#     # If the selction area is L * W < 20, we'll assume you were trying to select whichever
#     # window or output it was inside of to prevent accidental 2px snapshots
#     if [[ "$SELECTION" =~ ^([0-9]+),([0-9]+)[[:space:]]([0-9]+)x([0-9]+)$ ]]; then
#       if (( ${BASH_REMATCH[3]} * ${BASH_REMATCH[4]} < 20 )); then
#         click_x="${BASH_REMATCH[1]}"
#         click_y="${BASH_REMATCH[2]}"
#
#         while IFS= read -r rect; do
#           if [[ "$rect" =~ ^([0-9]+),([0-9]+)[[:space:]]([0-9]+)x([0-9]+) ]]; then
#             rect_x="${BASH_REMATCH[1]}"
#             rect_y="${BASH_REMATCH[2]}"
#             rect_width="${BASH_REMATCH[3]}"
#             rect_height="${BASH_REMATCH[4]}"
#
#             if (( click_x >= rect_x && click_x < rect_x+rect_width && click_y >= rect_y && click_y < rect_y+rect_height )); then
#               SELECTION="${rect_x},${rect_y} ${rect_width}x${rect_height}"
#               break
#             fi
#           fi
#         done <<< "$RECTS"
#       fi
#     fi
#     ;;
# esac
#
# [ -z "$SELECTION" ] && exit 0
#
# if [[ $PROCESSING == "slurp" ]]; then
# grim -g "$SELECTION" - |
#   satty --filename - \
#     --output-filename "$OUTPUT_DIR/screenshot-$(date +'%Y-%m-%d_%H-%M-%S').png" \
#     --early-exit \
#     --actions-on-enter save-to-clipboard \
#     --save-after-copy \
#     --copy-command 'wl-copy'
# else
#   grim -g "$SELECTION" - | wl-copy
# fi
#
#!/bin/bash

# Load user directories (Pictures folder, etc.)
[[ -f ~/.config/user-dirs.dirs ]] && source ~/.config/user-dirs.dirs
OUTPUT_DIR="${OMARCHY_SCREENSHOT_DIR:-${XDG_PICTURES_DIR:-$HOME/Pictures}}"

# Verify output directory exists
if [[ ! -d "$OUTPUT_DIR" ]]; then
  notify-send "Screenshot directory does not exist: $OUTPUT_DIR" -u critical -t 3000
  exit 1
fi

# Cancel previous slurp if running
pkill slurp && exit 0

MODE="${1:-smart}"
PROCESSING="${2:-slurp}"

# Helper: get rectangles for outputs and windows in active workspace
get_rectangles() {
  local active_workspace
  active_workspace=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .activeWorkspace.id')

  # Output rectangles (scaled)
  hyprctl monitors -j | jq -r --arg ws "$active_workspace" \
    '.[] | select(.activeWorkspace.id == ($ws | tonumber)) |
    "\(.x),\(.y) \((.width / .scale) | floor)x\((.height / .scale) | floor)"'

  # Window rectangles in that workspace
  hyprctl clients -j | jq -r --arg ws "$active_workspace" \
    '.[] | select(.workspace.id == ($ws | tonumber)) |
    "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"'
}

# Choose selection mode
case "$MODE" in
  region)
    SELECTION=$(slurp 2>/dev/null)
    ;;
  windows)
    SELECTION=$(get_rectangles | slurp -r 2>/dev/null)
    ;;
  fullscreen)
    SELECTION=$(hyprctl monitors -j | jq -r \
      '.[] | select(.focused == true) |
      "\(.x),\(.y) \((.width / .scale) | floor)x\((.height / .scale) | floor)"')
    ;;
  smart|*)
    RECTS=$(get_rectangles)
    SELECTION=$(echo "$RECTS" | slurp 2>/dev/null)

    # If selection area is too small, assume it was a click (select window/output)
    if [[ "$SELECTION" =~ ^([0-9]+),([0-9]+)[[:space:]]([0-9]+)x([0-9]+)$ ]]; then
      if (( ${BASH_REMATCH[3]} * ${BASH_REMATCH[4]} < 20 )); then
        click_x="${BASH_REMATCH[1]}"
        click_y="${BASH_REMATCH[2]}"

        while IFS= read -r rect; do
          if [[ "$rect" =~ ^([0-9]+),([0-9]+)[[:space:]]([0-9]+)x([0-9]+) ]]; then
            rect_x="${BASH_REMATCH[1]}"
            rect_y="${BASH_REMATCH[2]}"
            rect_width="${BASH_REMATCH[3]}"
            rect_height="${BASH_REMATCH[4]}"

            if (( click_x >= rect_x && click_x < rect_x+rect_width && click_y >= rect_y && click_y < rect_y+rect_height )); then
              SELECTION="${rect_x},${rect_y} ${rect_width}x${rect_height}"
              break
            fi
          fi
        done <<< "$RECTS"
      fi
    fi
    ;;
esac

# Exit if no selection
[ -z "$SELECTION" ] && exit 0

# Capture and process screenshot
if [[ $PROCESSING == "slurp" ]]; then
  grim -g "$SELECTION" - |
    satty --filename - \
      --early-exit \
      --copy-command 'wl-copy'
else
  grim -g "$SELECTION" - | wl-copy
fi
