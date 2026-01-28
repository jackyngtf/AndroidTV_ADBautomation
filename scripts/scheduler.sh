#!/bin/bash

# Default values (overridden by config.sh)
CURRENT_MODE="UNKNOWN"
CONFIG_FILE="/app/config.sh"

# Function to ensure ADB is connected
check_connection() {
    # If not connected to the specific IP, try to connect
    if ! adb devices | grep -q "$TV_IP.*device"; then
        echo "$(date): Device $TV_IP not found/connected. Attempting connect..."
        adb connect $TV_IP
        sleep 2
        
        # Wake up screen command right after connect to ensure it responds
        adb -s $TV_IP shell input keyevent KEYCODE_WAKEUP
    fi
}

start_vlc() {
    local TARGET_URL=$1
    local EXTRA_FLAGS=$2 # e.g. "--ez repeat true"
    
    echo "$(date): Launching VLC..."
    echo "  URL: $TARGET_URL"
    echo "  Flags: $EXTRA_FLAGS"
    
    check_connection
    # Ensure TV is awake
    adb -s $TV_IP shell input keyevent KEYCODE_WAKEUP
    
    # Start VLC
    # We use --ez from_start true to ensure it restarts if needed
    adb -s $TV_IP shell am start \
        -n $VLC_PKG/.gui.video.VideoPlayerActivity \
        -a android.intent.action.VIEW \
        -d "$TARGET_URL" \
        --ez "force_fullscreen" true \
        $EXTRA_FLAGS
}

set_sleep() {
    echo "$(date): Putting TV to Sleep..."
    check_connection
    # Stop media first
    adb -s $TV_IP shell input keyevent KEYCODE_MEDIA_STOP
    # Go to home to be safe
    adb -s $TV_IP shell input keyevent KEYCODE_HOME
    # Sleep
    adb -s $TV_IP shell input keyevent KEYCODE_SLEEP
}

# Main Loop
echo "Starting TV Automation Scheduler..."

while true; do
    # 1. Reload Config (allows changing times without restart)
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        echo "Error: Config file not found at $CONFIG_FILE"
    fi

    # 2. Get Current Time
    NOW=$(date +%H%M)
    
    # 3. Determine Scheduled State
    # Default to WORK
    DESIRED_MODE="WORK"
    
    # Check Sleep (Outside of working hours)
    if [ "$NOW" -lt "$START_DAY" ] || [ "$NOW" -ge "$END_DAY" ]; then
        DESIRED_MODE="SLEEP"
    else
        # Check News Slots
        for slot in "${NEWS_SLOTS[@]}"; do
            # strict format HHMM-HHMM
            START_TIME=${slot%-*}
            END_TIME=${slot#*-}
            
            if [ "$NOW" -ge "$START_TIME" ] && [ "$NOW" -lt "$END_TIME" ]; then
                DESIRED_MODE="NEWS"
                break
            fi
        done
    fi

    # 4. Apply State Change
    if [ "$CURRENT_MODE" != "$DESIRED_MODE" ]; then
        echo "$(date): Mode Change Detected! [$CURRENT_MODE] -> [$DESIRED_MODE]"
        
        case "$DESIRED_MODE" in
            "SLEEP")
                set_sleep
                ;;
            "NEWS")
                start_vlc "$NEWS_URL" "--ez from_start true" 
                # Note: clean stream usually doesn't need loop, it's a stream
                ;;
            "WORK")
                # Add loop flag for local file
                # VLC Android intent for loop is inconsistent but often defaults to playlist logic.
                # Just in case, we rely on the player settings or standard intent if supported.
                # --ez "repeat" true might work on some versions or just relaunch if it finishes (we can add logic for that later)
                # For now we just launch it.
                start_vlc "$WORK_VIDEO" "--ez repeat true"
                ;;
        esac
        
        CURRENT_MODE="$DESIRED_MODE"
    fi

    # 5. Heartbeat / State Maintenance
    # If we are in WORK mode, maybe ensure it's still playing? (Optional complexity)
    # For now we just sleep.
    
    # Check connection briefly to keep keep-alive
    if [ "$DESIRED_MODE" != "SLEEP" ]; then
         # Just listing devices helps keep the ADB server aware
         adb devices > /dev/null
    fi

    sleep 30
done
