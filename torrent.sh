#!/usr/bin/env bash

# qBittorrent Web UI API settings
QBITTORRENT_HOST="localhost"
QBITTORRENT_PORT="8080"
QBITTORRENT_API_URL="http://$QBITTORRENT_HOST:$QBITTORRENT_PORT/api/v2"

# ProtonVPN port forward file
PORT_FILE="/run/user/$UID/Proton/VPN/forwarded_port"

# Function to set qBittorrent listen port via Web UI API
set_qbittorrent_port() {
    local port="$1"
    local payload="json={\"listen_port\": $port}"

    response=$(curl -s -X POST -d "$payload" "$QBITTORRENT_API_URL/app/setPreferences")
    if [[ $? -eq 0 ]]; then
        echo "[$(date)] Successfully updated qBittorrent listen port to $port."
    else
        echo "[$(date)] ERROR: Failed to update qBittorrent listen port."
    fi
}

previous_port=""

while true; do
    if [[ ! -f "$PORT_FILE" ]]; then
        echo "[$(date)] ERROR: Port file not found at $PORT_FILE"
        sleep 45
        continue
    fi

    current_port=$(cat "$PORT_FILE" | tr -d '[:space:]')

    if [[ ! "$current_port" =~ ^[0-9]+$ ]]; then
        echo "[$(date)] ERROR: Invalid port value: '$current_port'"
        sleep 45
        continue
    fi

    echo "[$(date)] Forwarded port from file: $current_port"

    if [[ "$current_port" != "$previous_port" ]]; then
        echo "[$(date)] Port has changed. Updating qBittorrent..."
        set_qbittorrent_port "$current_port"
        previous_port="$current_port"
    else
        echo "[$(date)] Port unchanged. No action taken."
    fi

    sleep 45
done
