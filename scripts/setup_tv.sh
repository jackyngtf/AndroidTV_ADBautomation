#!/bin/bash
# =====================================================
# TV Setup Script - Run ONCE to configure TV settings
# =====================================================
# This script configures your Android TV to:
# 1. Keep WiFi ON during sleep (so ADB can wake it)
# 2. Disable WiFi idle timeout
#
# Usage (from your Synology or any machine with the container):
#   docker exec tv_automation bash /app/scripts/setup_tv.sh
#
# These settings persist across TV reboots - only run once.
# =====================================================

CONFIG_FILE="/app/config.sh"

# Load config
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Error: Config file not found. Using default TV_IP."
    TV_IP="10.10.216.7"
fi

echo "========================================="
echo " Android TV One-Time Setup"
echo " Target: $TV_IP"
echo "========================================="

# Ensure connection
echo ""
echo "[1/3] Connecting to TV..."
adb connect $TV_IP
sleep 2

# Check connection
if ! adb devices | grep -q "$TV_IP.*device"; then
    echo "ERROR: Cannot connect to TV at $TV_IP"
    echo "Make sure the TV is ON and USB debugging is enabled."
    exit 1
fi
echo "  ✓ Connected to $TV_IP"

# Keep WiFi ON during sleep
# wifi_sleep_policy values:
#   0 = Keep WiFi on when plugged in only
#   1 = Never keep WiFi on during sleep
#   2 = Always keep WiFi on during sleep
echo ""
echo "[2/3] Setting WiFi to stay ON during sleep..."
adb -s $TV_IP shell settings put global wifi_sleep_policy 2
RESULT=$(adb -s $TV_IP shell settings get global wifi_sleep_policy)
echo "  ✓ wifi_sleep_policy set to: $RESULT (2 = Always On)"

# Keep WiFi on even when idle (prevents WiFi from disconnecting)
echo ""
echo "[3/3] Disabling WiFi idle timeout..."
adb -s $TV_IP shell settings put global wifi_idle_ms 0
echo "  ✓ WiFi idle timeout disabled"

# Verify all settings
echo ""
echo "Verifying settings..."
echo "  wifi_sleep_policy:  $(adb -s $TV_IP shell settings get global wifi_sleep_policy)"
echo "  wifi_idle_ms:       $(adb -s $TV_IP shell settings get global wifi_idle_ms)"

echo ""
echo "========================================="
echo " Setup Complete!"
echo " WiFi will now stay ON during sleep."
echo " ADB can wake the TV remotely."
echo " These settings persist across reboots."
echo "========================================="

