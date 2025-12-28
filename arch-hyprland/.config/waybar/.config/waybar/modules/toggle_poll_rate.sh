#!/bin/bash

# Path to the poll_rate file
POLL_RATE_FILE="/sys/bus/hid/drivers/razermouse/0003:1532:00C1.0002/poll_rate"

# Read current poll rate
CURRENT_RATE=$(cat "$POLL_RATE_FILE")

# Toggle between 1000 and 8000
if [ "$CURRENT_RATE" -eq 1000 ]; then
    NEW_RATE=8000
else
    NEW_RATE=1000
fi

# Set new poll rate
echo "$NEW_RATE" | sudo tee "$POLL_RATE_FILE" > /dev/null

# Output the new rate for confirmation
# echo "Polling rate set to ${NEW_RATE}Hz"
