#!/bin/bash
# ── asus-profile.sh ───────────────────────────────────────  
# Description: Display current ASUS power profile with color
# Usage: Called by Waybar `custom/asus-profile`
# Dependencies: asusctl, awk
# ──────────────────────────────────────────────────────────  

profile=$(asusctl profile get | awk '/Active profile/ {print $NF}')

case "$profile" in
  Performance)
    text="PERFORMANCE"
    fg="#bf616a"
    ;;
  Balanced)
    text="BALANCED"
    fg="#fab387"
    ;;
  Quiet)
    text="QUIET"
    fg="#56b6c2"
    ;;
  *)
    text="ASUS ??"
    fg="#ffffff"
    ;;
esac

echo "<span foreground='$fg'>$text</span>"

