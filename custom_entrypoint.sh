#!/bin/bash
# custom_entrypoint.sh

# Execute the original entrypoint
./start.sh &

# Capture the PID of the background process
pid=$!

# Generate the client config
/client_config_generate.sh

# Wait for the original process to finish
wait $pid