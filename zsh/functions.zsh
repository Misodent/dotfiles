wifi-connect() {
	local ssid="$1"
	local pass="$2"
	
	if [[ "$pass" ]]; then
		nmcli device wifi connect "$ssid" password "$pass"
	else
		nmcli device wifi connect "$ssid"
	fi
}

wifi-delete() {
	nmcli connection delete $1
}
