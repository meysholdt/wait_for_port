#!/usr/bin/env bash
#
# wait_for_port.sh – Block until a local TCP port opens.
# Usage:  ./wait_for_port.sh <PORT>
# Example: ./wait_for_port.sh 5432   # wait for PostgreSQL

set -euo pipefail

# --- argument parsing -------------------------------------------------------
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <PORT>" >&2
    exit 1
fi

port="$1"
# rudimentary sanity check
if ! [[ "$port" =~ ^[0-9]+$ ]] || (( port < 1 || port > 65535 )); then
    echo "Error: \"$port\" is not a valid TCP port number." >&2
    exit 2
fi

# Get the IP address of eth0
iface="eth0"
ip=$(ip -4 addr show "$iface" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
if [[ -z "$ip" ]]; then
    echo "Error: Could not determine IP address for $iface." >&2
    exit 3
fi

echo "Waiting for port $port on $iface ($ip) to open..."

# --- main loop --------------------------------------------------------------
counter=0
while true; do
    # Try to open a TCP connection to $ip:$port.
    # /dev/tcp is a Bash builtin available on every standard Linux bash.
    if (exec 3<>/dev/tcp/$ip/"$port") 2>/dev/null; then
        echo "Port $port on $ip is open ✅"
        exit 0
    fi
    counter=$((counter + 1))
    if (( counter % 10 == 0 )); then
        echo "Still waiting… (checked $counter times)"
    fi
    sleep 1
done