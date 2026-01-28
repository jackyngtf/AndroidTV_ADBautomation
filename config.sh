#!/bin/bash

# --- CONNECTIVITY ---
TV_IP="10.10.216.7"

# --- MEDIA SOURCES ---
VLC_PKG="org.videolan.vlc"
# ABC News 24 Clean Stream (Updated)
NEWS_URL="https://c.mjh.nz/abc-news.m3u8"
# Local file on the TV's storage
WORK_VIDEO="file:///storage/emulated/0/Movies/company_video.mp4"

# --- SCHEDULE (24-hour format HHMM) ---
# Start of day: TV turns ON and plays Work Video
START_DAY="0830"
# End of day: TV turns OFF (Sleep)
END_DAY="1700"

# List of time ranges to play NEWS.
# Format: "START-END" (HHMM-HHMM)
# Example: "1200-1300" for 12 PM to 1 PM
NEWS_SLOTS=("1200-1300")
