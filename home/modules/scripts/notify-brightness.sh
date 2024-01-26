ID_FILE=/tmp/.notif_brightness_id

brightness=$((100 * $(brightnessctl get) / $(brightnessctl max)))
notif_id=$(cat $ID_FILE || echo -n "601")

notif_id=$(
  dunstify \
    --printid \
    --hints "int:value:$brightness" \
    --replace="$notif_id" \
    --icon=display-brightness-symbolic \
    --urgency=low \
    --timeout=1000 "Brightness" "$brightness %"
)

echo "$notif_id" > $ID_FILE
