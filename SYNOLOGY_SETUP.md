# Synology NAS Deployment Guide

## Volume Mount Configuration

On Synology NAS, Docker requires **absolute paths** for volume mounts. Based on your screenshot showing files in `/docker/tv_automation`, here's how to configure the mounts:

### In Synology Docker UI

For the `tv_automation` container, add these volume mounts:

| File/Folder (Local Path on NAS) | Mount Path (in Container) | Type |
|----------------------------------|---------------------------|------|
| `/docker/tv_automation/config.sh` | `/app/config.sh` | File |
| `/docker/tv_automation/scripts/scheduler.sh` | `/app/scheduler.sh` | File |
| `/docker/tv_automation/adb_keys` | `/root/.android` | Folder |

### Step-by-Step Instructions

1. **In Synology Docker UI**, select your `tv_automation` container
2. Click **Edit** (or **Settings** → **Volume** tab)
3. Click **Add Folder** or **Add File**
4. Configure each mount:

#### Mount 1: Config File
- **File/Folder**: Browse to `/docker/tv_automation/config.sh`
- **Mount path**: `/app/config.sh`
- Click **Select**

#### Mount 2: Scheduler Script
- **File/Folder**: Browse to `/docker/tv_automation/scripts/scheduler.sh`
- **Mount path**: `/app/scheduler.sh`
- Click **Select**

#### Mount 3: ADB Keys Folder
- **File/Folder**: Browse to `/docker/tv_automation/adb_keys`
- **Mount path**: `/root/.android`
- Click **Select**

### Important Notes

> [!WARNING]
> Make sure the `adb_keys` folder exists before mounting. If it doesn't exist:
> 1. SSH into your Synology or use File Station
> 2. Create folder: `/docker/tv_automation/adb_keys`
> 3. Set permissions: `chmod 755 /docker/tv_automation/adb_keys`

### Alternative: Use Docker Compose on Synology

If you prefer using `docker-compose.yml` on Synology:

1. **SSH into your Synology**
2. **Navigate to the project**:
   ```bash
   cd /docker/tv_automation
   ```

3. **Edit docker-compose.yml** to use absolute paths:
   ```yaml
   services:
     tv-controller:
       build: /docker/tv_automation
       container_name: tv_automation
       restart: unless-stopped
       network_mode: host
       environment:
         - TZ=Australia/Melbourne
       volumes:
         - /docker/tv_automation/config.sh:/app/config.sh
         - /docker/tv_automation/scripts/scheduler.sh:/app/scheduler.sh
         - /docker/tv_automation/adb_keys:/root/.android
   ```

4. **Run the container**:
   ```bash
   docker-compose down
   docker-compose up -d --build
   ```

### Verify Mounts

After configuring, check if files are accessible:

```bash
docker exec tv_automation ls -la /app/
```

You should see:
```
-rw-r--r-- 1 root root  562 Jan 28 14:12 config.sh
-rwxr-xr-x 1 root root 3456 Jan 28 13:56 scheduler.sh
```

### Troubleshooting

**If you still see "No such file or directory":**

1. **Check file permissions** on Synology:
   ```bash
   chmod +x /docker/tv_automation/scripts/scheduler.sh
   ```

2. **Verify paths exist**:
   ```bash
   ls -la /docker/tv_automation/
   ls -la /docker/tv_automation/scripts/
   ```

3. **Restart container** after fixing mounts:
   ```bash
   docker restart tv_automation
   ```

**If container won't start:**
- Check Synology Docker logs
- Ensure all source paths exist on the NAS
- Verify network_mode: host is supported on your Synology model
