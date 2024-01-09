#!/bin/bash
source "$(dirname ${BASH_SOURCE[0]})/bar.sh"

ID_FILE=/tmp/.notif_brightness_id
NOTIF_ID=$(cat $ID_FILE || echo "601")

brightness() {
    echo $((100 * `brightnessctl get` / `brightnessctl max`))
}

NOTIF_ID=$(
    dunstify --printid \
             --hints "int:value:$(brightness)" \
             --replace=$NOTIF_ID \
             --icon=display-brightness-symbolic \
             --urgency=low \
             --timeout=1000 "Brightness" "`brightness` %"
)

echo $NOTIF_ID > $ID_FILE
