#!/bin/bash
# ── vpn-status.sh ──────────────────────────────────────
# Description: Checks if VPN interface is active via IP range
# Usage: Called by Waybar `custom/vpn` every 5s
# Dependencies: ip, curl (optional, for country lookup)
# Output: Pango markup → [ФАНТОМ]: Country or KAPUTT
# Example: <span foreground='#fab387'>[ФАНТОМ]: Japan</span>
#          <span foreground='#bf616a'>[ФАНТОМ]: KAPUTT</span>
# ───────────────────────────────────────────────────────────

CACHE_FILE="/tmp/vpn_country_cache"
CACHE_TTL=300  # 5 minutes in seconds

get_cached_country() {
    if [[ ! -f "$CACHE_FILE" ]]; then
        return 1
    fi
    
    local cache_time=$(stat -f%m "$CACHE_FILE" 2>/dev/null || stat -c%Y "$CACHE_FILE" 2>/dev/null)
    local current_time=$(date +%s)
    local age=$((current_time - cache_time))
    
    if [[ $age -lt $CACHE_TTL ]]; then
        cat "$CACHE_FILE"
        return 0
    fi
    
    return 1
}

fetch_country() {
    # With timeout to prevent hanging
    curl -s --max-time 2 ifconfig.co/country-iso 2>/dev/null
}

if ip a | grep -q "100\."; then
    # VPN is active - try to get country
    country=$(get_cached_country)
    
    if [[ -z "$country" ]]; then
        # Cache miss, fetch from network
        country=$(fetch_country)
        [[ -z "$country" ]] && country="UNKNOWN"
        
        # Store in cache
        echo "$country" > "$CACHE_FILE"
    fi
    
    echo "<span foreground='#fab387'>[ VPN ] </span>""<span foreground='#56b6c2'>$country</span>"
else
    echo "<span foreground='#fab387'>[ VPN ] </span>""<span foreground='#bf616a'>KAPUTT</span>"
fi
