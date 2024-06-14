#!/bin/bash

RESOLVED_HOST_ADDR=$(curl -s -H "X-DockoVPN-Version: $(getVersion) $0" https://ip.dockovpn.io)

if [[ -n $HOST_ADDR ]]; then
    export HOST_ADDR_INT=$HOST_ADDR
else
    export HOST_ADDR_INT=$RESOLVED_HOST_ADDR
fi

# Path where the client.ovpn file is expected to appear
client_dir="/opt/Dockovpn_data/clients/"
CONTENT_TYPE="application/text"
FILE_NAME="client.ovpn"
FILE_PATH=""

# Wait for the client.ovpn file to be generated
echo "Waiting for client.ovpn to be generated..."
while true; do
    # Check if the directory with client.ovpn exists yet
    client_path=$(find "$client_dir" -type f -name "$FILE_NAME" -print -quit)
    if [[ -n "$client_path" ]]; then
        echo "File found: $client_path"
        FILE_PATH="$client_path"
        break
    fi
    sleep 1
done

# Check if FILE_PATH is correctly assigned
if [[ -z "$FILE_PATH" ]]; then
    echo "Error: FILE_PATH is not set or empty."
    exit 1
fi

# Perform modifications
echo "Modifying $FILE_PATH..."
sed -i '/<cert>/,/<\/cert>/d' "$FILE_PATH"
sed -i '/<key>/,/<\/key>/d' "$FILE_PATH"
sed -i '/^;client-id/d' "$FILE_PATH"
sed -i '/<ca>/i explicit-exit-notify 1' "$FILE_PATH"
echo "Adding <auth-user-pass> section to $FILE_PATH..."
{
    echo "<auth-user-pass>"
    echo "USERNAME_PLACEHOLDER"
    echo "PASSWORD_PLACEHOLDER"
    echo "</auth-user-pass>"
} >> "$FILE_PATH"

# Kill the currently running server process to serve the updated client.ovpn and run a new one
echo "Shutting down current server..."
echo "$(date) Starting http server to serve updated client config..."
killall nc
echo "$(date) Config server started, download your updated client config at http://$HOST_ADDR_INT:$HOST_CONF_PORT/"
echo "$(date) NOTE: After you download your client config, the http server will be shut down!"
{ echo -ne "HTTP/1.1 200 OK\r\nContent-Length: $(wc -c <$FILE_PATH)\r\nContent-Type: $CONTENT_TYPE\r\nContent-Disposition: attachment; fileName=\"$FILE_NAME\"\r\nAccept-Ranges: bytes\r\n\r\n"; cat "$FILE_PATH"; } | nc -w0 -l 8080
echo "$(date) Config http server has been shut down"
echo "Modifications complete. Continuing with other processes..."