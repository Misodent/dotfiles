#!/bin/bash
# ── vpn-status.sh ──────────────────────────────────────
# Description: Checks if VPN interface is active via IP range
# Usage: Called by Waybar `custom/vpn` every 5s
# Dependencies: ip, curl (optional, for country lookup)
# Output: Pango markup → [ФАНТОМ]: Country or KAPUTT
# Example: <span foreground='#fab387'>[ФАНТОМ]: Japan</span>
#          <span foreground='#bf616a'>[ФАНТОМ]: KAPUTT</span>
# ───────────────────────────────────────────────────────────

#!/bin/bash

if ip a | grep -q "100\."; then
  country=$(curl -s ifconfig.co/country-iso 2>/dev/null)
  [[ -z "$country" ]] && country="UNKNOWN"
  echo "<span foreground='#fab387'>[ VPN ] </span>""<span foreground='#56b6c2'>$country</span>"
else
  echo "<span foreground='#fab387'>[ VPN ] </span>""<span foreground='#bf616a'>KAPUTT</span>"
fi