#!/bin/bash
sleep 1

while true; do
    wallpaper=$(find -L /home/dboj/Pictures/wp/cycle_wp -type f | shuf -n 1)
    hyprctl hyprpaper preload $wallpaper
    
    sleep 1
    hyprctl hyprpaper wallpaper ,$wallpaper
    # notify-send -i "Wallpaper changed"
    
    sleep 4h
done
