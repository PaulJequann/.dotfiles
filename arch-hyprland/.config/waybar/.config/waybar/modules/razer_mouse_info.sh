#!/bin/bash

CHARGE_LEVEL=$(cat /sys/bus/hid/drivers/razermouse/0003:1532:00C1.0002/charge_level)
DPI=$(cat /sys/bus/hid/drivers/razermouse/0003:1532:00C1.0002/dpi)
POLL_RATE=$(cat /sys/bus/hid/drivers/razermouse/0003:1532:00C1.0002/poll_rate)

PERCENTAGE=$((CHARGE_LEVEL * 100 / 255))

echo "{\"text\": \"$PERCENTAGE\", \"tooltip\": \"DPI: $DPI\\nPoll Rate: $POLL_RATE Hz\"}"