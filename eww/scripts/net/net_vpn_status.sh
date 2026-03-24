#!/usr/bin/env bash
# $HOME/.config/eww/scripts/net/net_vpn_status.sh
# Show VPN status + country (for Eww)

if /usr/bin/ipsec statusall 2>/dev/null | grep -q "ESTABLISHED"; then
  country=$(curl -s ifconfig.co/country 2>/dev/null)
  [[ -z "$country" ]] && country="UNKNOWN"
  echo "[FANTOM]"
else
  echo "KAPOT"
fi

