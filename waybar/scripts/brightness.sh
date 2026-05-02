#!/bin/bash
# ── brightness.sh ─────────────────────────────────────────
# Description: Shows current brightness with ASCII bar + tooltip
# Usage: Waybar `custom/brightness` every 2s
# Dependencies: brightnessctl, seq, printf, awk
#  ─────────────────────────────────────────────────────────

# Get brightness percentage
brightness=$(brightnessctl get)
max_brightness=$(brightnessctl max)
percent=$((brightness * 100 / max_brightness))

# Build ASCII bar
filled=$((percent / 10))
empty=$((10 - filled))
bar=""
for ((i=0; i<filled; i++)); do
    bar+="█"
done
for ((i=0; i<empty; i++)); do
    bar+="░"
done
ascii_bar="[$bar]"

# Icon
icon="󰛨"

# Color thresholds
if [ "$percent" -lt 20 ]; then
    fg="#bf616a"  # red
elif [ "$percent" -lt 55 ]; then
    fg="#fab387"  # orange
else
    fg="#56b6c2"  # cyan
fi

# Device name (first column from brightnessctl --machine-readable)
device=$(brightnessctl --machine-readable | awk -F, 'NR==1 {print $1}')

# Tooltip text
tooltip="Brightness: $percent%\nDevice: $device"

# JSON output
echo "{\"text\":\"<span foreground='$fg'>$icon $ascii_bar $percent%</span>\",\"tooltip\":\"$tooltip\"}"

