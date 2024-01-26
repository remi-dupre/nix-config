# Usage : ./screenshot.sh <MODE>
# Parameters
#   MODE : screen | area | window

MODE=$1
OUTPUT_FILE=/tmp/screenshot_$(date +"%Y-%m-%dT%H:%M:%S").png

grimshot copy "$MODE"
wl-paste > "$OUTPUT_FILE"
dunstify --icon "$OUTPUT_FILE" "Saved $MODE to clipboard" "$OUTPUT_FILE"
