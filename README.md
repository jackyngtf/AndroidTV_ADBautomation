# Android TV Automation with ADB

Automated content scheduling for Android TV using ADB and Docker. This system automatically plays different content based on time schedules - perfect for workplace TVs showing news during lunch and training videos during work hours.

## Features

- ⏰ **Time-Based Scheduling**: Automatically switch content based on configurable time slots
- 🔄 **State-Based Logic**: Handles mid-day restarts gracefully (if container restarts at 12:30, it correctly starts lunch content)
- 🔐 **Persistent ADB Authentication**: One-time TV authorization (no repeated prompts)
- ⚡ **Hot Configuration**: Edit schedules without rebuilding containers
- 🌐 **Live Streaming Support**: Play live streams (ABC News) and local video files
- 📺 **Power Management**: Automatically turn TV on/off based on business hours

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- Android TV with ADB enabled (Settings → Device Preferences → About → Build Number - tap 7 times → Developer options → USB debugging)
- Network connectivity to your TV

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/jackyngtf/AndroidTV_ADBautomation.git
   cd AndroidTV_ADBautomation
   ```

2. **Edit configuration**
   ```bash
   # Edit config.sh with your settings
   nano config.sh
   ```

3. **Start the container**
   ```bash
   docker-compose up -d --build
   ```

4. **Authorize ADB on TV (First time only)**
   - Look at your TV screen
   - You'll see "Allow USB debugging?" prompt
   - Check "Always allow from this computer"
   - Click "OK"

5. **Restart container once** (to ensure keys are saved)
   ```bash
   docker-compose restart
   ```

## Configuration

All settings are in [`config.sh`](config.sh). You can edit this file anytime - changes are picked up automatically within 30 seconds.

```bash
# TV Connection
TV_IP="10.10.216.7"          # Your Android TV IP address

# Media Sources
NEWS_URL="https://c.mjh.nz/abc-news.m3u8"    # Live stream URL
WORK_VIDEO="file:///storage/.../video.mp4"   # Local video on TV

# Schedule (24-hour format HHMM)
START_DAY="0830"    # TV turns ON at 8:30 AM
END_DAY="1700"      # TV turns OFF at 5:00 PM

# News Time Slots (can have multiple)
NEWS_SLOTS=("1200-1300" "1430-1530")
# This plays news from 12:00-1:00 PM and 2:30-3:30 PM
```

### How to Find Your TV IP

1. On your Android TV, go to: **Settings → Network & Internet → Your WiFi → Advanced**
2. Note the IP address (e.g., `10.10.216.7`)

### How to Find Video Paths on TV

Use a file manager app on your TV (like VLC or X-plore) to find the full path to your video file. 

**Important:** Use `file://` prefix and URL encoding for spaces:
- ✅ Correct: `file:///storage/emulated/0/My%20Video.mp4`
- ❌ Wrong: `/storage/emulated/0/My Video.mp4`

## File Structure

```
tv_automation/
├── docker-compose.yml      # Docker configuration
├── Dockerfile              # Container image definition
├── config.sh              # ⚙️ YOUR SETTINGS (edit this)
├── scripts/
│   └── scheduler.sh       # Main logic (rarely needs edits)
└── adb_keys/              # ADB authentication keys (auto-generated)
```

## Usage

### Start the System
```bash
docker-compose up -d --build
```

### Stop the System
```bash
docker-compose down
```

### View Logs
```bash
# View all logs
docker logs tv_automation

# Follow logs in real-time
docker logs -f tv_automation
```

### Restart After Config Change
The container automatically reloads `config.sh` every 30 seconds, so **you don't need to restart** after editing schedules.

If you want to restart anyway:
```bash
docker-compose restart
```

## Schedule Logic

The script checks time every 30 seconds and applies this logic:

1. **Before START_DAY or after END_DAY**: TV in SLEEP mode
2. **During NEWS_SLOTS**: Plays News stream
3. **All other times (between START_DAY and END_DAY)**: Plays Work Video

**Example Timeline** (with default config):
- `08:30` - TV wakes up, plays Work Video
- `12:00` - Switches to ABC News
- `13:00` - Switches back to Work Video
- `17:00` - TV goes to sleep

## Troubleshooting

### TV Not Responding

1. **Check ADB connection**
   ```bash
   docker exec -it tv_automation adb devices
   ```
   You should see: `10.10.216.7:5555    device`

2. **Check if TV has USB Debugging enabled**
   - Settings → Device Preferences → Developer options → USB debugging

3. **Manually connect**
   ```bash
   docker exec -it tv_automation adb connect 10.10.216.7
   ```

### "Unauthorized" Error

This means the TV hasn't authorized the connection:
1. Look at TV screen for the authorization prompt
2. Select "Always allow"
3. Click OK

### Video Not Playing

1. **Check the path is correct**
   - Use VLC on the TV to open the file manually
   - Copy the exact path shown in VLC

2. **Ensure spaces are URL-encoded**
   - Replace spaces with `%20`
   - Example: `My Video.mp4` → `My%20Video.mp4`

### Container Keeps Restarting

Check logs:
```bash
docker logs tv_automation
```

Common issues:
- Config file has syntax errors (missing quotes, etc.)
- Network connectivity issues

## Advanced Configuration

### Multiple News Slots

Edit `config.sh`:
```bash
NEWS_SLOTS=("1200-1300" "1430-1530" "1600-1630")
```

This will play news:
- 12:00 PM - 1:00 PM
- 2:30 PM - 3:30 PM  
- 4:00 PM - 4:30 PM

### Custom Actions

You can modify `scripts/scheduler.sh` to add custom behaviors:
- Play different videos on different days
- Send notifications
- Control other smart devices

## How It Works

1. **Docker Container** runs a Bash script on Alpine Linux
2. **ADB (Android Debug Bridge)** connects to your TV over network
3. **Scheduler Script** checks time every 30 seconds and:
   - Loads current config from `config.sh`
   - Determines what state TV should be in (SLEEP/NEWS/WORK)
   - If state changed, sends ADB commands to:
     - Wake/sleep the TV
     - Launch VLC with the correct URL
4. **Persistent Keys** in `adb_keys/` folder ensure you only authorize once

## Security Notes

- ADB access grants full control of your TV
- Use this only on trusted networks
- Consider adding authentication if exposing the container externally

## Contributing

Feel free to submit issues or pull requests!

## License

MIT License - feel free to use and modify for your needs.

## Credits

Created for workplace TV automation to show:
- ABC News during lunch breaks
- Company training videos during work hours
