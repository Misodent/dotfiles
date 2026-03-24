#!/bin/bash
# ── vpn-toggle.sh ─────────────────────────────────────────
# Description: Toggle VPN on/off via systemd service
# Usage: Called by Waybar `custom/vpn` on click
# Dependencies: systemctl, ip
# ──────────────────────────────────────────────────────────

if ip a | grep -q "100\."; then
  # VPN active → stop service (disconnect)
  tailscale down
else
  # VPN inactive → start service (connect)
  tailscale up
fi
